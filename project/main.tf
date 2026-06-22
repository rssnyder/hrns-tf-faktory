data "harness_platform_organization" "org" {
  identifier = var.org_id
}

resource "harness_platform_project" "project" {
  count = var.create_project ? 1 : 0

  identifier = var.project_id
  name       = var.project_id
  org_id     = data.harness_platform_organization.org.id
}

data "harness_platform_project" "project" {
  count = var.create_project ? 0 : 1

  identifier = var.project_id
  org_id     = data.harness_platform_organization.org.id
}
