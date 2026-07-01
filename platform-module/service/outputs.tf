output "service_id" {
  description = "Platform service resource ID"
  value       = harness_platform_service.platform.id
}

output "service_identifier" {
  description = "Platform service identifier"
  value       = harness_platform_service.platform.identifier
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
