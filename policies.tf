resource "harness_platform_policy" "template_enforcement" {
  identifier  = "template_enforcement"
  name        = "Template Enforcement"
  description = "Enforce template usage in pipelines"
  rego        = file("${path.module}/templates/policies/template_enforcement.rego")
}

resource "harness_platform_policy" "allowed_modules" {
  identifier  = "allowed_modules"
  name        = "Allowed Modules"
  description = "Enforce allowed modules in pipelines"
  rego        = file("${path.module}/templates/policies/allowed_modules.rego")
}

resource "harness_platform_policyset" "iacm_pipeline" {
  identifier = "iacm_pipeline"
  name       = "IaCM Pipeline Policy Set"
  action     = "onsave"
  type       = "pipeline"
  enabled    = true

  policy_references {
    identifier = harness_platform_policy.template_enforcement.identifier
    severity   = "warning"
  }
}

resource "harness_platform_policyset" "iacm_plan" {
  identifier = "iacm_plan"
  name       = "IaCM Plan Policy Set"
  action     = "afterTerraformPlan"
  type       = "terraformPlan"
  enabled    = true

  policy_references {
    identifier = harness_platform_policy.allowed_modules.identifier
    severity   = "warning"
  }
}