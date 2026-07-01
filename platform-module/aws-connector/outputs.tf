output "cloud_connector_id" {
  description = "Cloud connector resource ID"
  value       = harness_platform_connector_aws.cloud.id
}

output "cloud_connector_identifier" {
  description = "Cloud connector identifier"
  value       = harness_platform_connector_aws.cloud.identifier
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
