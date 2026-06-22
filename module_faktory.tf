data "harness_platform_organization" "module_faktory_org" {
  identifier = var.module_faktory_org_id
}

resource "harness_platform_project" "module_faktory" {
  identifier = replace(replace(var.module_faktory_project_name, " ", "_"), "-", "_")
  name       = var.module_faktory_project_name
  org_id     = data.harness_platform_organization.module_faktory_org.id
}

# module testing pipelines do not currently support using stage templates
# resource "harness_platform_pipeline" "test" {
#   org_id     = data.harness_platform_organization.module_faktory_org.id
#   project_id = harness_platform_project.module_faktory.identifier

#   identifier  = "TF_Module_Test"
#   name        = "TF Module Test"
#   description = "Test infrastructure module changes"
#   tags        = local.common_tags_tuple
#   yaml = templatefile(
#     "${path.module}/templates/pipelines/generic_stage_template.yaml",
#     {
#       PIPELINE_IDENTIFIER : "TF_Module_Test"
#       PIPELINE_NAME : "TF Module Test"
#       ORGANIZATION_ID : data.harness_platform_organization.module_faktory_org.id
#       PROJECT_ID : harness_platform_project.module_faktory.identifier
#       PIPELINE_DESCRIPTION : "Test infrastructure module changes"
#       STAGE_NAME : "TF Module Test"
#       STAGE_IDENTIFIER : "TF_Module_Test"
#       STAGE_TEMPLATE_REF : "account.${harness_platform_template.test.identifier}"
#       STAGE_TEMPLATE_VERSION : harness_platform_template.test.version

#       STAGE_INPUT_KEY : "moduleId"

#       TAGS : yamlencode(local.common_tags)
#     }
#   )
# }

# resource "harness_platform_pipeline" "integration_test" {
#   org_id     = data.harness_platform_organization.module_faktory_org.id
#   project_id = harness_platform_project.module_faktory.identifier

#   identifier  = "TF_Module_Integration_Test"
#   name        = "TF Module Integration Test"
#   description = "Test infrastructure module changes"
#   tags        = local.common_tags_tuple
#   yaml = templatefile(
#     "${path.module}/templates/pipelines/generic_stage_template.yaml",
#     {
#       PIPELINE_IDENTIFIER : "TF_Module_Integration_Test"
#       PIPELINE_NAME : "TF Module Integration Test"
#       ORGANIZATION_ID : data.harness_platform_organization.module_faktory_org.id
#       PROJECT_ID : harness_platform_project.module_faktory.identifier
#       PIPELINE_DESCRIPTION : "Test infrastructure module changes"
#       STAGE_NAME : "TF Module Integration Test"
#       STAGE_IDENTIFIER : "TF_Module_Integration_Test"
#       STAGE_TEMPLATE_REF : "account.${harness_platform_template.integration_test.identifier}"
#       STAGE_TEMPLATE_VERSION : harness_platform_template.integration_test.version

#       STAGE_INPUT_KEY : "moduleId"

#       TAGS : yamlencode(local.common_tags)
#     }
#   )
# }

# for now we do inline pipelines
resource "harness_platform_pipeline" "testing" {
  org_id     = data.harness_platform_organization.module_faktory_org.id
  project_id = harness_platform_project.module_faktory.identifier

  identifier  = "TF_Module_Testing"
  name        = "TF Module Testing"
  description = "Test infrastructure module changes"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/testing_pipeline_inline.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Module_Testing"
      PIPELINE_NAME : "TF Module Testing"
      ORGANIZATION_ID : data.harness_platform_organization.module_faktory_org.id
      PROJECT_ID : harness_platform_project.module_faktory.identifier
      PIPELINE_DESCRIPTION : "Test infrastructure module changes"

      IACM_STAGE_INFRASTRUCTURE : "    ${indent(4, local.IACM_STAGE_INFRASTRUCTURE)}"
      IACM_TESTING_COMMAND : "test"

      TAGS : yamlencode(local.common_tags)
    }
  )
}

resource "harness_platform_pipeline" "integration_testing" {
  org_id     = data.harness_platform_organization.module_faktory_org.id
  project_id = harness_platform_project.module_faktory.identifier

  identifier  = "TF_Module_Integration_Testing"
  name        = "TF Module Integration Testing"
  description = "Test infrastructure module changes"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/testing_pipeline_inline.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Module_Integration_Testing"
      PIPELINE_NAME : "TF Module Integration Testing"
      ORGANIZATION_ID : data.harness_platform_organization.module_faktory_org.id
      PROJECT_ID : harness_platform_project.module_faktory.identifier
      PIPELINE_DESCRIPTION : "Test infrastructure module changes"

      IACM_STAGE_INFRASTRUCTURE : "    ${indent(4, local.IACM_STAGE_INFRASTRUCTURE)}"
      IACM_TESTING_COMMAND : "integration-test"

      TAGS : yamlencode(local.common_tags)
    }
  )
}

module "this" {
  source = "./module"

  name                 = "example"
  description          = "example"
  system               = "example"
  repository_connector = "account.github_com"
  repository           = "rssnyder/terraform-module-example"
  repository_branch    = "main"
  repository_path      = ""
  provider_connector   = "account.asdf"
  provisioner_type     = "opentofu"
  provisioner_version  = "1.12.0"
  testing_pipelines = [
    harness_platform_pipeline.testing.identifier,
    harness_platform_pipeline.integration_testing.identifier
  ]

  org_id     = data.harness_platform_organization.module_faktory_org.id
  project_id = harness_platform_project.module_faktory.identifier
}