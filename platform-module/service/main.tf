# ---------------------------------------------------------------------------
# CD Service
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

  # Auto-derive identifier from name (like aws-connector and infrastructure)
  service_identifier = lower(replace(replace(var.service_name, " ", "_"), "/[^a-z0-9_]/", "_"))

  task_definition_manifest_store_yaml = var.manifest_store_type == "Harness" ? (
    <<-YAML
type: Harness
spec:
  files:
    - ${var.task_definition_manifest_path}
YAML
    ) : (
    <<-YAML
type: Github
spec:
  connectorRef: ${var.git_connector_ref}
  gitFetchType: Branch
  paths:
    - ${var.task_definition_manifest_path}
  repoName: ${var.git_repo_name}
  branch: ${var.git_branch}
YAML
  )

  service_definition_manifest_store_yaml = var.manifest_store_type == "Harness" ? (
    <<-YAML
type: Harness
spec:
  files:
    - ${var.service_definition_manifest_path}
YAML
    ) : (
    <<-YAML
type: Github
spec:
  connectorRef: ${var.git_connector_ref}
  gitFetchType: Branch
  paths:
    - ${var.service_definition_manifest_path}
  repoName: ${var.git_repo_name}
  branch: ${var.git_branch}
YAML
  )
}

resource "terraform_data" "validation" {
  lifecycle {
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
  identifier  = local.service_identifier
  name        = var.service_name
  description = var.service_description
  org_id      = local.org_id
  project_id  = local.project_id
  tags        = local.common_tags_tuple

  yaml = <<-EOT
    service:
      name: ${var.service_name}
      identifier: ${local.service_identifier}
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
                    ${indent(16, local.task_definition_manifest_store_yaml)}
            - manifest:
                identifier: ${var.service_definition_manifest_identifier}
                type: EcsServiceDefinition
                spec:
                  store:
                    ${indent(16, local.service_definition_manifest_store_yaml)}
          artifacts:
            primary:
              primaryArtifactRef: <+input>
              sources: []
  EOT
}
