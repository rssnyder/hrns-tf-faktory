# Infrastructure Sub-module

Creates Harness infrastructure definitions and infrastructure-specific overrides for existing environments.

**Note:** This module does NOT create environments. Environment identifiers must already exist.

## Resources

- `harness_platform_infrastructure` - Infrastructure definitions per environment
- `harness_platform_service_overrides_v2` - INFRA_GLOBAL_OVERRIDE per environment (optional)

## Usage

### Basic Example

```hcl
module "infrastructure" {
  source = "./infrastructure"

  org_id     = "default"
  project_id = "platform_engineering"

  # Reference the connector from aws-connector module
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  default_cluster     = "production-ecs-cluster"

  # Map keys must match existing environment identifiers
  infrastructure_configs = {
    dev = {
      cluster = "dev-cluster"
    }
    prod = {
      cluster = "prod-cluster"
    }
  }
}
```

### Complete Example with Infrastructure Overrides

```hcl
module "infrastructure" {
  source = "./infrastructure"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # AWS configuration
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  deployment_type     = "ECS"

  # Default settings
  default_cluster                  = "default-ecs-cluster"
  infrastructure_identifier_suffix = "_infrastructure"
  allow_simultaneous_deployments   = false

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

  # Enable infrastructure overrides
  create_infra_overrides = true

  # Default override values
  default_load_balancer          = "default-platform-alb"
  default_prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-alb/abc123/def456"
  default_prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/default-alb/abc123/def456/ghi789"

  # Infrastructure configurations per environment
  # Keys must match existing environment identifiers
  infrastructure_configs = {
    dev = {
      cluster                = "dev-ecs-cluster"
      infrastructure_identifier = "dev_infra"
      infrastructure_name       = "Development ECS"
      load_balancer             = "dev-api-alb-12345"
      prod_listener             = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/dev-api-alb/abc123/def456"
      prod_listener_rule_arn    = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/dev-api-alb/abc123/def456/ghi789"
    }
    testing = {
      load_balancer = "test-api-alb-12345"
      # Uses default_cluster and default listener values
    }
    stage = {
      cluster       = "stage-ecs-cluster"
      load_balancer = "stage-api-alb-12345"
    }
    prod = {
      cluster                = "prod-ecs-cluster"
      load_balancer          = "prod-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/prod-api-alb/abc123/def456"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/prod-api-alb/abc123/def456/ghi789"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| aws_connector_ref | AWS connector identifier | string | - | yes |
| aws_region | AWS region | string | "us-east-1" | no |
| default_cluster | Default ECS cluster name | string | "default" | no |
| create_infra_overrides | Create infrastructure overrides | bool | true | no |
| default_load_balancer | Default load balancer for overrides | string | - | no |
| infrastructure_configs | Infrastructure configurations per environment | map(object) | {} | yes |

**Important:** Keys in `infrastructure_configs` must match existing environment identifiers. This module does not create environments.

## Outputs

| Name | Description |
|------|-------------|
| infrastructure_ids | Infrastructure definition resource IDs |
| infrastructure_identifiers | Infrastructure identifiers |
| infra_override_ids | Infrastructure override resource IDs (if enabled) |
| org_id | Organization ID |
| project_id | Project ID |
