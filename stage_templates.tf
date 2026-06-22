resource "harness_platform_template" "plan" {
  identifier = "TF_Plan"
  name       = "TF Plan"
  comments   = "Plan infrastructure changes"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/plan.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_Plan"
      TEMPLATE_NAME : "TF Plan"
      TEMPLATE_COMMENTS : "Plan infrastructure changes"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      TF_STEP : local.TF_STEP

      CHECKOV_FAIL_ON_SEVERITY : var.checkov_fail_on_severity

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}

resource "harness_platform_template" "apply" {
  identifier = "TF_Apply"
  name       = "TF Apply"
  comments   = "Apply infrastructure changes"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/apply.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_Apply"
      TEMPLATE_NAME : "TF Apply"
      TEMPLATE_COMMENTS : "Apply infrastructure changes"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      TF_STEP : local.TF_STEP

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}

resource "harness_platform_template" "destroy" {
  identifier = "TF_Destroy"
  name       = "TF Destroy"
  comments   = "Destroy infrastructure changes"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/destroy.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_Destroy"
      TEMPLATE_NAME : "TF Destroy"
      TEMPLATE_COMMENTS : "Destroy infrastructure changes"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      TF_STEP : local.TF_STEP

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}

resource "harness_platform_template" "detect_drift" {
  identifier = "TF_DetectDrift"
  name       = "TF Detect Drift"
  comments   = "Detect infrastructure drift"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/drift.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_DetectDrift"
      TEMPLATE_NAME : "TF Detect Drift"
      TEMPLATE_COMMENTS : "Detect infrastructure drift"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE
      TF_STEP : local.TF_STEP

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}

resource "harness_platform_template" "test" {
  identifier = "TF_Test"
  name       = "TF Test"
  comments   = "Test infrastructure module changes"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/test.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_Test"
      TEMPLATE_NAME : "TF Test"
      TEMPLATE_COMMENTS : "Test infrastructure module changes"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}

resource "harness_platform_template" "integration_test" {
  identifier = "TF_Integration_Test"
  name       = "TF Integration Test"
  comments   = "Integration test infrastructure module changes"
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/integration-test.yaml",
    {
      TEMPLATE_IDENTIFIER : "TF_Integration_Test"
      TEMPLATE_NAME : "TF Integration Test"
      TEMPLATE_COMMENTS : "Integration test infrastructure module changes"
      TEMPLATE_VERSION : "v1"

      IACM_STAGE_INFRASTRUCTURE : local.IACM_STAGE_INFRASTRUCTURE

      TAGS : yamlencode(local.common_tags)
    }
  )

  tags = local.common_tags_tuple
}