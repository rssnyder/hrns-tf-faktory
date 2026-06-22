resource "harness_platform_pipeline" "plan" {
  identifier  = "TF_Plan"
  org_id      = data.harness_platform_organization.org.id
  project_id  = local.project_id
  name        = "TF Plan"
  description = "Plan infrastructure changes"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/generic_stage_template.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Plan"
      PIPELINE_NAME : "TF Plan"
      ORGANIZATION_ID : data.harness_platform_organization.org.id
      PROJECT_ID : local.project_id
      PIPELINE_DESCRIPTION : "Plan infrastructure changes"
      STAGE_NAME : "TF Plan"
      STAGE_IDENTIFIER : "TF_Plan"
      STAGE_TEMPLATE_REF : var.plan_stage_template_ref
      STAGE_TEMPLATE_VERSION : var.plan_stage_template_version

      TAGS : yamlencode(local.common_tags)
    }
  )
}

resource "harness_platform_pipeline" "apply" {
  identifier  = "TF_Apply"
  org_id      = data.harness_platform_organization.org.id
  project_id  = local.project_id
  name        = "TF Apply"
  description = "Apply infrastructure changes"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/generic_stage_template.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Apply"
      PIPELINE_NAME : "TF Apply"
      ORGANIZATION_ID : data.harness_platform_organization.org.id
      PROJECT_ID : local.project_id
      PIPELINE_DESCRIPTION : "Apply infrastructure changes"
      STAGE_NAME : "TF Apply"
      STAGE_IDENTIFIER : "TF_Apply"
      STAGE_TEMPLATE_REF : var.apply_stage_template_ref
      STAGE_TEMPLATE_VERSION : var.apply_stage_template_version

      TAGS : yamlencode(local.common_tags)
    }
  )
}

resource "harness_platform_pipeline" "destroy" {
  identifier  = "TF_Destroy"
  org_id      = data.harness_platform_organization.org.id
  project_id  = local.project_id
  name        = "TF Destroy"
  description = "Destroy infrastructure"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/generic_stage_template.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Destroy"
      PIPELINE_NAME : "TF Destroy"
      ORGANIZATION_ID : data.harness_platform_organization.org.id
      PROJECT_ID : local.project_id
      PIPELINE_DESCRIPTION : "Destroy infrastructure"
      STAGE_NAME : "TF Destroy"
      STAGE_IDENTIFIER : "TF_Destroy"
      STAGE_TEMPLATE_REF : var.destroy_stage_template_ref
      STAGE_TEMPLATE_VERSION : var.destroy_stage_template_version

      TAGS : yamlencode(local.common_tags)
    }
  )
}

resource "harness_platform_pipeline" "drift" {
  identifier  = "TF_Drift"
  org_id      = data.harness_platform_organization.org.id
  project_id  = local.project_id
  name        = "TF Drift"
  description = "Detect infrastructure drift"
  tags        = local.common_tags_tuple
  yaml = templatefile(
    "${path.module}/templates/pipelines/generic_stage_template.yaml",
    {
      PIPELINE_IDENTIFIER : "TF_Drift"
      PIPELINE_NAME : "TF Drift"
      ORGANIZATION_ID : data.harness_platform_organization.org.id
      PROJECT_ID : local.project_id
      PIPELINE_DESCRIPTION : "Detect infrastructure drift"
      STAGE_NAME : "TF Drift"
      STAGE_IDENTIFIER : "TF_Drift"
      STAGE_TEMPLATE_REF : var.drift_stage_template_ref
      STAGE_TEMPLATE_VERSION : var.drift_stage_template_version

      TAGS : yamlencode(local.common_tags)
    }
  )
}