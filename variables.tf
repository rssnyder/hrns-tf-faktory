// project for platform pipelines
variable "platform_org_id" {
  type        = string
  description = "Organization ID for platform pipelines"
  default     = "default"
}

variable "platform_project_name" {
  type        = string
  description = "Project name for platform pipelines"
  default     = "Platform"
}

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

// generic
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

// idp stage template for creating repos from a template

// for creating new repos
variable "git_connector_type" {
  type        = string
  description = "Git connector type"
  default     = "Github"
}

variable "git_connector_ref" {
  type        = string
  description = "Git connector reference"
}

variable "is_personal_account" {
  type        = bool
  description = "Whether the git connector is a personal account"
  default     = false
}

variable "git_org" {
  type        = string
  description = "Git organization"
}

// for cloning cookiecutter template
variable "template_clone_connector_ref" {
  type        = string
  description = "Template clone connector reference"
}

variable "template_clone_repo_name" {
  type        = string
  description = "Template clone repo name"
}

variable "template_clone_branch" {
  type        = string
  description = "Template clone branch"
  default     = "main"
}

// default branch for created repos
variable "repo_branch" {
  type        = string
  description = "Repo branch"
  default     = "main"
}