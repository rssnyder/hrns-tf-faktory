locals {
  // Standard tags applied to all managed resources
  required_tags = {
    created_by : "Terraform"
  }

  common_tags = merge(local.required_tags, var.tags)

  // Convert tags from map to list format (Harness API requirement)
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  project_id = var.create_project ? harness_platform_project.project[0].id : data.harness_platform_project.project[0].id
}