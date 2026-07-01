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

# ---------------------------------------------------------------------------
# Cloud connector
# ---------------------------------------------------------------------------

variable "cloud_connector_identifier" {
  description = "Cloud connector identifier (lowercase, underscores allowed)"
  type        = string
  default     = "cloud_connector"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.cloud_connector_identifier))
    error_message = "cloud_connector_identifier must start with a letter and contain only lowercase letters, numbers, and underscores."
  }
}

variable "cloud_connector_name" {
  description = "Display name for the cloud connector"
  type        = string
  default     = "Cloud Connector"
}

variable "cloud_connector_description" {
  description = "Description for the cloud connector"
  type        = string
  default     = "Cloud connector using Harness OIDC authentication"
}

variable "cloud_connector_tags" {
  description = "Tags for the cloud connector (Harness key:value format)"
  type        = set(string)
  default     = []
}

variable "iam_role_arn" {
  description = "AWS IAM role ARN that Harness OIDC will assume"
  type        = string
  default     = "arn:aws:iam::568258498023:role/harness-demo-oidc-role"
}

variable "cloud_region" {
  description = "Cloud region for connector test and infrastructure definitions"
  type        = string
  default     = "us-east-1"
}

variable "delegate_selectors" {
  description = "Delegate selectors for OIDC credential inheritance"
  type        = set(string)
  default     = []
}

variable "execute_on_delegate" {
  description = "Run connector operations on a delegate when true"
  type        = bool
  default     = false
}

variable "fixed_backoff" {
  description = "Fixed backoff delay in milliseconds for cloud API retries. Null omits backoff override."
  type        = number
  default     = null
}

variable "retry_count" {
  description = "Retry count when fixed_backoff is set"
  type        = number
  default     = 0
}
