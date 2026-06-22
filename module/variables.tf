variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "system" {
  type = string
}

variable "repository_connector" {
  type = string
}

variable "repository" {
  type = string
}

variable "repository_branch" {
  type = string
}

variable "repository_path" {
  type = string
}

variable "provider_connector" {
  type = string
}

variable "provisioner_type" {
  type = string
}

variable "provisioner_version" {
  type = string
}

variable "testing_pipelines" {
  type = list(string)
}