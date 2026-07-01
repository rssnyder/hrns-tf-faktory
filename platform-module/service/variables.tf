# ---------------------------------------------------------------------------
# Scope
# ---------------------------------------------------------------------------

variable "org_id" {
  description = "Harness organization identifier"
  type        = string
}

variable "project_id" {
  description = "Harness project identifier (must already exist)"
  type        = string
}

variable "tags" {
  description = "Additional tags applied to platform resources. Merged over default_tags (same key wins)."
  type        = map(string)
  default     = {}
}

variable "default_tags" {
  description = "Baseline tags applied to all platform resources unless overridden by tags."
  type        = map(string)
  default = {
    team = "platform"
  }
}

# ---------------------------------------------------------------------------
# CD service
# ---------------------------------------------------------------------------

variable "service_name" {
  description = "Harness service name (identifier will be auto-derived from this)"
  type        = string
}

variable "service_description" {
  description = "Harness service description"
  type        = string
  default     = "Harness service managed by Terraform"
}

variable "deployment_type" {
  description = "Harness deployment type for service"
  type        = string
  default     = "ECS"
}

variable "manifest_store_type" {
  description = "Manifest store for ECS task/service definitions: Github or Harness"
  type        = string
  default     = "Github"

  validation {
    condition     = contains(["Github", "Harness"], var.manifest_store_type)
    error_message = "manifest_store_type must be Github or Harness."
  }
}

variable "git_connector_ref" {
  description = "Git connector identifier when manifest_store_type is Github (e.g. Shared Services connector)"
  type        = string
  default     = null
}

variable "git_repo_name" {
  description = "Git repository name when manifest_store_type is Github"
  type        = string
  default     = null
}

variable "git_branch" {
  description = "Git branch when manifest_store_type is Github"
  type        = string
  default     = "main"
}

variable "task_definition_manifest_identifier" {
  description = "Harness manifest identifier for the ECS task definition"
  type        = string
  default     = "task"
}

variable "service_definition_manifest_identifier" {
  description = "Harness manifest identifier for the ECS service definition"
  type        = string
  default     = "service"
}

variable "task_definition_manifest_path" {
  description = "Path to ECS task definition manifest (Git path or Harness File Store path)"
  type        = string
  default     = "ecs/taskdef.json"
}

variable "service_definition_manifest_path" {
  description = "Path to ECS service definition manifest (Git path or Harness File Store path)"
  type        = string
  default     = "ecs/service.json"
}
