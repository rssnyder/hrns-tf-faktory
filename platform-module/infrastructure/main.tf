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

  # Derive infrastructure name if not provided
  infra_name = coalesce(var.infrastructure_name, "${var.environment_id} Infrastructure")

  # Auto-derive identifier from name (like aws-connector)
  infra_identifier = lower(replace(replace(local.infra_name, " ", "_"), "/[^a-z0-9_]/", "_"))
}

# ---------------------------------------------------------------------------
# Infrastructure definition
# ---------------------------------------------------------------------------

resource "harness_platform_infrastructure" "this" {
  identifier      = local.infra_identifier
  name            = local.infra_name
  org_id          = local.org_id
  project_id      = local.project_id
  env_id          = var.environment_id
  type            = var.deployment_type
  deployment_type = var.deployment_type
  tags            = local.common_tags_tuple

  yaml = <<-EOT
    infrastructureDefinition:
      name: ${local.infra_name}
      identifier: ${local.infra_identifier}
      orgIdentifier: ${local.org_id}
      projectIdentifier: ${local.project_id}
      environmentRef: ${var.environment_id}
      deploymentType: ${var.deployment_type}
      type: ${var.deployment_type}
      spec:
        connectorRef: ${var.aws_connector_ref}
        region: ${var.aws_region}
        cluster: ${var.cluster}
      allowSimultaneousDeployments: ${var.allow_simultaneous_deployments}
  EOT
}

# ---------------------------------------------------------------------------
# Infrastructure-specific overrides (INFRA_GLOBAL_OVERRIDE)
# ---------------------------------------------------------------------------

resource "harness_platform_service_overrides_v2" "this" {
  count = var.create_infra_overrides ? 1 : 0

  org_id     = local.org_id
  project_id = local.project_id
  env_id     = var.environment_id
  infra_id   = harness_platform_infrastructure.this.identifier
  type       = "INFRA_GLOBAL_OVERRIDE"

  yaml = <<-EOT
    variables:
      - name: load_balancer
        type: String
        value: "${coalesce(var.load_balancer, var.default_load_balancer)}"
      - name: prod_listener
        type: String
        value: "${coalesce(var.prod_listener, var.default_prod_listener)}"
      - name: prod_listener_rule_arn
        type: String
        value: "${coalesce(var.prod_listener_rule_arn, var.default_prod_listener_rule_arn)}"
  EOT
}
