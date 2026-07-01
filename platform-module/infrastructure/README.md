# Infrastructure Sub-module

Creates Harness environments and infrastructure definitions.

## Resources

- `harness_platform_environment` - CD environments
- `harness_platform_infrastructure` - Infrastructure definitions per environment

## Usage

### Basic Example

```hcl
module "infrastructure" {
  source = "./infrastructure"

  org_id     = "default"
  project_id = "platform_engineering"

  # Reference the connector from aws-connector module
  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  cloud_region        = "us-east-1"
  default_cluster     = "production-ecs-cluster"

  environments = {
    dev = {
      name = "Development"
      type = "PreProduction"
    }
    prod = {
      name = "Production"
      type = "Production"
    }
  }
}
```

### Complete Example with Per-Environment Customization

```hcl
module "infrastructure" {
  source = "./infrastructure"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # Cloud configuration
  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  cloud_region        = "us-east-1"
  deployment_type     = "ECS"

  # Default settings
  default_cluster                = "default-ecs-cluster"
  infrastructure_identifier_suffix = "_infrastructure"
  allow_simultaneous_deployments = false

  # Tags
  tags = {
    managed_by = "terraform"
    project    = "platform"
  }

  default_tags = {
    team = "platform-engineering"
  }

  # Per-environment cluster overrides
  cluster_overrides = {
    prod = "production-ecs-cluster"
  }

  # Environment definitions
  environments = {
    dev = {
      name                      = "Development"
      type                      = "PreProduction"
      cluster                   = "dev-ecs-cluster"
      infrastructure_identifier = "dev_infra"
      infrastructure_name       = "Development ECS"
    }
    testing = {
      name = "Testing"
      type = "PreProduction"
      # Uses default_cluster
    }
    stage = {
      name    = "Staging"
      type    = "PreProduction"
      cluster = "stage-ecs-cluster"
    }
    prod = {
      name    = "Production"
      type    = "Production"
      cluster = "prod-ecs-cluster"
    }
  }
}

# Output infrastructure identifiers for use in service-overrides module
output "infra_ids" {
  value = module.infrastructure.infrastructure_identifiers
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| cloud_connector_ref | Cloud connector identifier | string | - | yes |
| cloud_region | AWS region | string | "us-east-1" | no |
| default_cluster | Default ECS cluster name | string | "default" | no |
| environments | Environment configurations | map(object) | See variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| environment_ids | Environment resource IDs |
| environment_identifiers | Environment identifiers |
| infrastructure_ids | Infrastructure definition resource IDs |
| infrastructure_identifiers | Infrastructure identifiers (pass to service-overrides) |
| org_id | Organization ID |
| project_id | Project ID |
