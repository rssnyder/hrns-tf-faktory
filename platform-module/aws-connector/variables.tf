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
# AWS connector
# ---------------------------------------------------------------------------

variable "aws_connector_name" {
  description = "Display name for the AWS connector (identifier will be derived from this)"
  type        = string
}

variable "aws_connector_description" {
  description = "Description for the AWS connector"
  type        = string
  default     = "AWS connector using Harness OIDC authentication"
}

variable "aws_connector_tags" {
  description = "Tags for the AWS connector (Harness key:value format)"
  type        = set(string)
  default     = []
}

variable "iam_role_arn" {
  description = "AWS IAM role ARN that Harness OIDC will assume"
  type        = string
}

variable "aws_region" {
  description = "AWS region for connector test and infrastructure definitions"
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
