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
# Infrastructure configuration
# ---------------------------------------------------------------------------

variable "cloud_connector_ref" {
  description = "Cloud connector reference for infrastructure (use connector identifier for project-scoped connectors)"
  type        = string
}

variable "cloud_region" {
  description = "Cloud region for infrastructure definitions"
  type        = string
  default     = "us-east-1"
}

variable "deployment_type" {
  description = "Harness deployment type for infrastructure"
  type        = string
  default     = "ECS"
}

variable "default_cluster" {
  description = "Default cluster name when not set per environment"
  type        = string
  default     = "default"
}

variable "cluster_overrides" {
  description = "Per-environment cluster overrides (keyed by environment identifier)"
  type        = map(string)
  default     = {}
}

variable "infrastructure_identifier_suffix" {
  description = "Suffix appended to environment key for infrastructure identifier when not explicitly set"
  type        = string
  default     = "_infra"
}

variable "allow_simultaneous_deployments" {
  description = "Allow simultaneous deployments on infrastructure definitions"
  type        = bool
  default     = false
}

variable "environments" {
  description = "Harness CD environments to create. Map key is the environment identifier."
  type = map(object({
    name                      = string
    type                      = string
    cluster                   = optional(string)
    infrastructure_identifier = optional(string)
    infrastructure_name       = optional(string)
  }))

  default = {
    dev = {
      name = "Dev"
      type = "PreProduction"
    }
    testing = {
      name = "Testing"
      type = "PreProduction"
    }
    stage = {
      name = "Stage"
      type = "PreProduction"
    }
    prod = {
      name = "Prod"
      type = "Production"
    }
  }
}
