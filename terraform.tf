terraform {
  required_providers {
    // Harness Terraform provider for managing platform resources
    harness = {
      source  = "harness/harness"
      version = ">= 0.43.6"
    }
  }
}
