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
# Feature flags
# ---------------------------------------------------------------------------

variable "create_infra_overrides" {
  description = "Create INFRA_GLOBAL_OVERRIDE per environment/infrastructure (Infrastructure Specific tab in Harness UI)."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# CD service
# ---------------------------------------------------------------------------

variable "service_identifier" {
  description = "Harness service identifier"
  type        = string
  default     = "platform_service"
}

variable "service_name" {
  description = "Harness service display name"
  type        = string
  default     = "Platform Service"
}

variable "service_description" {
  description = "Harness service description"
  type        = string
  default     = "Platform service managed by Terraform"
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

# ---------------------------------------------------------------------------
# Infrastructure overrides
# ---------------------------------------------------------------------------

variable "default_load_balancer" {
  description = "Default load_balancer infra override value when not set per environment"
  type        = string
  default     = "idis1e-alb-dev"
}

variable "default_prod_listener" {
  description = "Default prod_listener infra override ARN when not set per environment"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-1:000000000000:listener/app/example/alb-id/abc123/def456"
}

variable "default_prod_listener_rule_arn" {
  description = "Default prod_listener_rule_arn infra override ARN when not set per environment"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-1:000000000000:listener-rule/app/example/alb-id/abc123/def456/ghi789"
}

variable "environments" {
  description = "Environment configurations for overrides (keyed by environment identifier). Required when create_infra_overrides is true."
  type = map(object({
    load_balancer          = optional(string)
    prod_listener          = optional(string)
    prod_listener_rule_arn = optional(string)
  }))
  default = null
}

variable "infrastructure_identifiers" {
  description = "Map of environment identifier to infrastructure identifier (from infrastructure module output)"
  type        = map(string)
  default     = {}
}
