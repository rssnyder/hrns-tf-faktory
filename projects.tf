module "project" {
  source = "./project"

  org_id     = "default"
  project_id = "rssnyder"

  plan_stage_template_ref     = "account.${harness_platform_template.plan.identifier}"
  plan_stage_template_version = harness_platform_template.plan.version

  apply_stage_template_ref     = "account.${harness_platform_template.apply.identifier}"
  apply_stage_template_version = harness_platform_template.apply.version

  destroy_stage_template_ref     = "account.${harness_platform_template.destroy.identifier}"
  destroy_stage_template_version = harness_platform_template.destroy.version

  drift_stage_template_ref     = "account.${harness_platform_template.detect_drift.identifier}"
  drift_stage_template_version = harness_platform_template.detect_drift.version

  tags = local.common_tags
}
