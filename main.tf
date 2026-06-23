data "harness_platform_current_account" "platform_account" {}

data "harness_platform_organization" "platform_org" {
  identifier = var.platform_org_id
}

resource "harness_platform_project" "platform_project" {
  identifier = replace(replace(var.platform_project_name, " ", "_"), "-", "_")
  name       = var.platform_project_name
  org_id     = data.harness_platform_organization.platform_org.id
}