# ---------------------------------------------------------------------------
# Environments and Infrastructure Definitions
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

  infrastructure_identifiers = {
    for key, env in var.environments : key => coalesce(
      env.infrastructure_identifier,
      "${key}${var.infrastructure_identifier_suffix}"
    )
  }

  infrastructure_names = {
    for key, env in var.environments : key => coalesce(
      env.infrastructure_name,
      "${env.name} ${var.deployment_type}"
    )
  }
}

# ---------------------------------------------------------------------------
# Environments
# ---------------------------------------------------------------------------

resource "harness_platform_environment" "platform" {
  for_each = var.environments

  identifier = each.key
  name       = each.value.name
  org_id     = local.org_id
  project_id = local.project_id
  type       = each.value.type
  tags       = local.common_tags_tuple

  yaml = <<-EOT
    environment:
      name: ${each.value.name}
      identifier: ${each.key}
      orgIdentifier: ${local.org_id}
      projectIdentifier: ${local.project_id}
      type: ${each.value.type}
  EOT
}

# ---------------------------------------------------------------------------
# Infrastructure definitions
# ---------------------------------------------------------------------------

resource "harness_platform_infrastructure" "platform" {
  for_each = var.environments

  identifier      = local.infrastructure_identifiers[each.key]
  name            = local.infrastructure_names[each.key]
  org_id          = local.org_id
  project_id      = local.project_id
  env_id          = harness_platform_environment.platform[each.key].identifier
  type            = var.deployment_type
  deployment_type = var.deployment_type
  tags            = local.common_tags_tuple

  yaml = <<-EOT
    infrastructureDefinition:
      name: ${local.infrastructure_names[each.key]}
      identifier: ${local.infrastructure_identifiers[each.key]}
      orgIdentifier: ${local.org_id}
      projectIdentifier: ${local.project_id}
      environmentRef: ${each.key}
      deploymentType: ${var.deployment_type}
      type: ${var.deployment_type}
      spec:
        connectorRef: ${var.cloud_connector_ref}
        region: ${var.cloud_region}
        cluster: ${coalesce(try(each.value.cluster, null), lookup(var.cluster_overrides, each.key, var.default_cluster))}
      allowSimultaneousDeployments: ${var.allow_simultaneous_deployments}
  EOT
}

# ---------------------------------------------------------------------------
# Infrastructure-specific overrides (INFRA_GLOBAL_OVERRIDE)
# ---------------------------------------------------------------------------

resource "harness_platform_service_overrides_v2" "infra" {
  for_each = var.create_infra_overrides ? var.environments : {}

  org_id     = local.org_id
  project_id = local.project_id
  env_id     = harness_platform_environment.platform[each.key].identifier
  infra_id   = harness_platform_infrastructure.platform[each.key].identifier
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
