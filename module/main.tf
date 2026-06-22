resource "harness_platform_infra_module" "this" {
  name        = var.name
  description = var.description
  system      = var.system

  repository_connector = var.repository_connector
  repository           = var.repository
  repository_branch    = var.repository_branch
  repository_path      = var.repository_path


  # onboarding_pipeline         = "my_onboarding_pipeline"
  # onboarding_pipeline_org     = "default"
  # onboarding_pipeline_project = "IaCM_Project"
  # onboarding_pipeline_sync    = true

  # storage_type                = "artifact"
  # connector_org               = "default"
  # connector_project           = "my_project"
}

resource "harness_platform_infra_module_testing" "this" {
  module_id           = harness_platform_infra_module.this.id
  org                 = var.org_id
  project             = var.project_id
  provider_connector  = var.provider_connector
  provisioner_type    = var.provisioner_type
  provisioner_version = var.provisioner_version
  pipelines           = var.testing_pipelines
}