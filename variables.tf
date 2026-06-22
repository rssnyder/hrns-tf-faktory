// k8s config for stage templates
variable "kubernetes_connector" {
  type        = string
  description = "Kubernetes connector reference for pipeline execution (use 'skipped' for Harness-managed infrastructure)"
  default     = "skipped"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Kubernetes namespace for pipeline execution"
  default     = "default"
}

variable "kubernetes_serviceaccount" {
  type        = string
  description = "Kubernetes service account for pipeline execution (use 'skipped' for default)"
  default     = "skipped"
}

variable "kubernetes_override_run_as_user" {
  type        = string
  description = "Kubernetes pod runAs user ID override (must be a valid Unix integer, or 'skipped')"
  default     = "skipped"

  validation {
    condition = (
      var.kubernetes_override_run_as_user != null
      ?
      var.kubernetes_override_run_as_user != "skipped"
      ?
      can(tonumber(var.kubernetes_override_run_as_user))
      :
      true
      :
      false
    )
    error_message = "Kubernetes runAs user must be a valid Unix integer or 'skipped'."
  }
}

variable "kubernetes_node_selectors" {
  type        = map(any)
  description = "Kubernetes node selectors for pod scheduling"
  default     = {}
}

variable "kubernetes_override_image_connector" {
  type        = string
  description = "Container registry connector for custom provisioner images (use 'skipped' for default)"
  default     = "skipped"
}

variable "kubernetes_override_image_name" {
  type        = string
  description = "Custom container image for provisioner (terraform/opentofu binary). Path relative to kubernetes_override_image_connector"
  default     = "skipped"
}

// provisioner config for stage templates
variable "provisioner_type" {
  type        = string
  description = "Default provisioner type: 'terraform' or 'opentofu'"
  default     = "opentofu"
}

variable "plugin_image" {
  type        = string
  description = "Custom plugin image for tf steps"
  default     = "skipped"
}

variable "plugin_connector" {
  type        = string
  description = "Custom plugin connector for tf steps"
  default     = "skipped"
}

// scanner settings
variable "checkov_fail_on_severity" {
  type        = string
  description = "Checkov fail on severity"
  default     = "high"
  validation {
    condition     = var.checkov_fail_on_severity == "none" || var.checkov_fail_on_severity == "low" || var.checkov_fail_on_severity == "medium" || var.checkov_fail_on_severity == "high" || var.checkov_fail_on_severity == "critical"
    error_message = "checkov_fail_on_severity must be one of: none, low, medium, high, critical"
  }
}

// project for module testing
variable "module_faktory_org_id" {
  type        = string
  description = "Organization ID for module testing"
  default     = "default"
}

variable "module_faktory_project_name" {
  type        = string
  description = "Project name for module testing"
  default     = "Module Testing"
}

// generic
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
