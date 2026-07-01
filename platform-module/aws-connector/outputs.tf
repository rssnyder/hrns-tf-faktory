output "aws_connector_id" {
  description = "AWS connector resource ID"
  value       = harness_platform_connector_aws.aws.id
}

output "aws_connector_identifier" {
  description = "AWS connector identifier (derived from name)"
  value       = harness_platform_connector_aws.aws.identifier
}

output "org_id" {
  description = "Harness organization ID"
  value       = local.org_id
}

output "project_id" {
  description = "Harness project ID"
  value       = local.project_id
}
