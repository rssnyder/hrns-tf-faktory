# ---------------------------------------------------------------------------
# CD Service and Infrastructure Overrides
# ---------------------------------------------------------------------------

data "harness_platform_organization" "org" {
  identifier = var.org_id
}

data "harness_platform_project" "platform" {
  identifier = var.project_id
  org_id     = data.harness_platform_organization.org.id
}

locals {
  org_id     = data.harness_platform_organization.org.id
  project_id = data.harness_platform_project.platform.id

  common_tags       = merge(var.default_tags, var.tags)
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  task_definition_manifest_store_yaml = var.manifest_store_type == "Harness" ? <<-YAML
type: Harness
spec:
  files:
    - ${var.task_definition_manifest_path}
YAML
  : <<-YAML
type: Github
spec:
  connectorRef: ${var.git_connector_ref}
  gitFetchType: Branch
  paths:
    - ${var.task_definition_manifest_path}
  repoName: ${var.git_repo_name}
  branch: ${var.git_branch}
YAML

  service_definition_manifest_store_yaml = var.manifest_store_type == "Harness" ? <<-YAML
type: Harness
spec:
  files:
    - ${var.service_definition_manifest_path}
YAML
  : <<-YAML
type: Github
spec:
  connectorRef: ${var.git_connector_ref}
  gitFetchType: Branch
  paths:
    - ${var.service_definition_manifest_path}
  repoName: ${var.git_repo_name}
  branch: ${var.git_branch}
YAML
}

resource "terraform_data" "validation" {
  lifecycle {
    precondition {
      condition     = !var.create_infra_overrides || var.environments != null
      error_message = "environments must be provided when create_infra_overrides is true."
    }

    precondition {
      condition     = var.manifest_store_type != "Github" || (var.git_connector_ref != null && var.git_repo_name != null)
      error_message = "git_connector_ref and git_repo_name are required when manifest_store_type is Github."
    }
  }
}

# ---------------------------------------------------------------------------
# CD service
# ---------------------------------------------------------------------------

resource "harness_platform_service" "platform" {
  identifier  = var.service_identifier
  name        = var.service_name
  description = var.service_description
  org_id      = local.org_id
  project_id  = local.project_id
  tags        = local.common_tags_tuple

  yaml = <<-EOT
    service:
      name: ${var.service_name}
      identifier: ${var.service_identifier}
      orgIdentifier: ${local.org_id}
      projectIdentifier: ${local.project_id}
      serviceDefinition:
        type: ${var.deployment_type}
        spec:
          manifests:
            - manifest:
                identifier: ${var.task_definition_manifest_identifier}
                type: EcsTaskDefinition
                spec:
                  store:
${indent(20, local.task_definition_manifest_store_yaml)}
            - manifest:
                identifier: ${var.service_definition_manifest_identifier}
                type: EcsServiceDefinition
                spec:
                  store:
${indent(20, local.service_definition_manifest_store_yaml)}
          artifacts:
            primary:
              primaryArtifactRef: <+input>
              sources: []
  EOT
}

# ---------------------------------------------------------------------------
# Infrastructure-specific overrides (INFRA_GLOBAL_OVERRIDE)
# ---------------------------------------------------------------------------

resource "harness_platform_service_overrides_v2" "infra" {
  for_each = var.create_infra_overrides ? var.environments : {}

  org_id     = local.org_id
  project_id = local.project_id
  env_id     = each.key
  infra_id   = var.infrastructure_identifiers[each.key]
  type       = "INFRA_GLOBAL_OVERRIDE"

  yaml = <<-EOT
    variables:
      - name: load_balancer
        type: String
        value: "${coalesce(try(each.value.load_balancer, null), var.default_load_balancer)}"
      - name: prod_listener
        type: String
        value: "${coalesce(try(each.value.prod_listener, null), var.default_prod_listener)}"
      - name: prod_listener_rule_arn
        type: String
        value: "${coalesce(try(each.value.prod_listener_rule_arn, null), var.default_prod_listener_rule_arn)}"
  EOT
}
