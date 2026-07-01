output "service_id" {
  description = "Platform service resource ID"
  value       = harness_platform_service.platform.id
}

output "service_identifier" {
  description = "Platform service identifier"
  value       = harness_platform_service.platform.identifier
}

output "infra_override_ids" {
  description = "INFRA_GLOBAL_OVERRIDE IDs keyed by environment identifier"
  value       = { for k, override in harness_platform_service_overrides_v2.infra : k => override.id }
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
