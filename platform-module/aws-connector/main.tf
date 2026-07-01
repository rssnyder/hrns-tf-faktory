# ---------------------------------------------------------------------------
# AWS Cloud Connector (OIDC)
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
}

resource "harness_platform_connector_aws" "cloud" {
  identifier          = var.cloud_connector_identifier
  name                = var.cloud_connector_name
  description         = var.cloud_connector_description
  org_id              = local.org_id
  project_id          = local.project_id
  tags                = var.cloud_connector_tags
  execute_on_delegate = var.execute_on_delegate

  dynamic "fixed_delay_backoff_strategy" {
    for_each = var.fixed_backoff != null ? [1] : []
    content {
      fixed_backoff = var.fixed_backoff
      retry_count   = var.retry_count
    }
  }

  oidc_authentication {
    iam_role_arn       = var.iam_role_arn
    region             = var.cloud_region
    delegate_selectors = var.delegate_selectors
  }
}
