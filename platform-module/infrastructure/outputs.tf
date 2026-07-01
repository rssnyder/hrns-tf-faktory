output "infrastructure_id" {
  description = "Infrastructure definition resource ID"
  value       = harness_platform_infrastructure.this.id
}

output "infrastructure_identifier" {
  description = "Infrastructure definition identifier"
  value       = harness_platform_infrastructure.this.identifier
}

output "infrastructure_name" {
  description = "Infrastructure definition name"
  value       = harness_platform_infrastructure.this.name
}

output "infra_override_id" {
  description = "INFRA_GLOBAL_OVERRIDE resource ID (if created)"
  value       = var.create_infra_overrides ? harness_platform_service_overrides_v2.this[0].id : null
}

output "environment_id" {
  description = "Environment identifier this infrastructure is associated with"
  value       = var.environment_id
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
