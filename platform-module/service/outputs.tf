output "service_id" {
  description = "Service resource ID"
  value       = harness_platform_service.platform.id
}

output "service_identifier" {
  description = "Service identifier (derived from name)"
  value       = harness_platform_service.platform.identifier
}

output "service_name" {
  description = "Service name"
  value       = harness_platform_service.platform.name
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
