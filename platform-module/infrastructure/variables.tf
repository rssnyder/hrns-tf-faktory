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

variable "aws_connector_ref" {
  description = "AWS connector reference for infrastructure (use connector identifier for project-scoped connectors)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for infrastructure definitions"
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

# ---------------------------------------------------------------------------
# Feature flags
# ---------------------------------------------------------------------------

variable "create_infra_overrides" {
  description = "Create INFRA_GLOBAL_OVERRIDE per environment/infrastructure (Infrastructure Specific tab in Harness UI)."
  type        = bool
  default     = true
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

variable "infrastructure_configs" {
  description = "Infrastructure configurations per environment. Map key must be an existing environment identifier."
  type = map(object({
    cluster                   = optional(string)
    load_balancer             = optional(string)
    prod_listener             = optional(string)
    prod_listener_rule_arn    = optional(string)
    infrastructure_identifier = optional(string)
    infrastructure_name       = optional(string)
  }))

  default = {
    dev = {}
    testing = {}
    stage = {}
    prod = {}
  }
}
