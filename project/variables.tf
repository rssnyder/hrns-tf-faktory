variable "create_project" {
  type    = bool
  default = true
}

variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "plan_stage_template_ref" {
  type = string
}

variable "plan_stage_template_version" {
  type = string
}

variable "apply_stage_template_ref" {
  type = string
}

variable "apply_stage_template_version" {
  type = string
}

variable "destroy_stage_template_ref" {
  type = string
}

variable "destroy_stage_template_version" {
  type = string
}

variable "drift_stage_template_ref" {
  type = string
}

variable "drift_stage_template_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

