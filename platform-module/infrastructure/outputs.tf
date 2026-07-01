output "environment_ids" {
  description = "Environment resource IDs keyed by environment identifier"
  value       = { for k, env in harness_platform_environment.platform : k => env.id }
}

output "environment_identifiers" {
  description = "Environment identifiers keyed by environment identifier"
  value       = { for k, env in harness_platform_environment.platform : k => env.identifier }
}

output "infrastructure_ids" {
  description = "Infrastructure definition resource IDs keyed by environment identifier"
  value       = { for k, infra in harness_platform_infrastructure.platform : k => infra.id }
}

output "infrastructure_identifiers" {
  description = "Infrastructure definition identifiers keyed by environment identifier"
  value       = { for k, infra in harness_platform_infrastructure.platform : k => infra.identifier }
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
