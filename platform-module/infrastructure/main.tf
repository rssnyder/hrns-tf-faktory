# ---------------------------------------------------------------------------
# Infrastructure Definitions
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
    for key, config in var.infrastructure_configs : key => coalesce(
      config.infrastructure_identifier,
      "${key}${var.infrastructure_identifier_suffix}"
    )
  }

  infrastructure_names = {
    for key, config in var.infrastructure_configs : key => coalesce(
      config.infrastructure_name,
      "${key} ${var.deployment_type}"
    )
  }
}

# ---------------------------------------------------------------------------
# Infrastructure definitions
# ---------------------------------------------------------------------------

resource "harness_platform_infrastructure" "platform" {
  for_each = var.infrastructure_configs

  identifier      = local.infrastructure_identifiers[each.key]
  name            = local.infrastructure_names[each.key]
  org_id          = local.org_id
  project_id      = local.project_id
  env_id          = each.key
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
        connectorRef: ${var.aws_connector_ref}
        region: ${var.aws_region}
        cluster: ${coalesce(try(each.value.cluster, null), lookup(var.cluster_overrides, each.key, var.default_cluster))}
      allowSimultaneousDeployments: ${var.allow_simultaneous_deployments}
  EOT
}

# ---------------------------------------------------------------------------
# Infrastructure-specific overrides (INFRA_GLOBAL_OVERRIDE)
# ---------------------------------------------------------------------------

resource "harness_platform_service_overrides_v2" "infra" {
  for_each = var.create_infra_overrides ? var.infrastructure_configs : {}

  org_id     = local.org_id
  project_id = local.project_id
  env_id     = each.key
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
