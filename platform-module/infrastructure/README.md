# Infrastructure Sub-module

Creates a single Harness infrastructure definition and optional infrastructure-specific overrides for an existing environment.

The infrastructure identifier is automatically derived from the infrastructure name.

**Note:** This module does NOT create environments. The environment identifier must already exist.

## Resources

- `harness_platform_infrastructure` - Single infrastructure definition
- `harness_platform_service_overrides_v2` - INFRA_GLOBAL_OVERRIDE (optional)

## Usage

### Basic Example

```hcl
module "dev_infrastructure" {
  source = "./infrastructure"

  org_id     = "default"
  project_id = "platform_engineering"

  # Must reference an existing environment
  environment_id = "dev"

  # Infrastructure name (identifier: dev_infrastructure)
  infrastructure_name = "Dev Infrastructure"

  # Reference the connector from aws-connector module
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  cluster           = "dev-ecs-cluster"
}
```

### Complete Example with Infrastructure Overrides

```hcl
module "prod_infrastructure" {
  source = "./infrastructure"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # Must reference an existing environment
  environment_id = "prod"

  # Infrastructure name (identifier auto-derived: production_main_infrastructure)
  infrastructure_name = "Production Main Infrastructure"

  # AWS configuration
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  deployment_type   = "ECS"

  # Infrastructure settings
  cluster                        = "prod-ecs-cluster"
  allow_simultaneous_deployments = false

  # Tags
  tags = {
    managed_by = "terraform"
    env        = "production"
  }

  default_tags = {
    team = "platform-engineering"
  }

  # Enable infrastructure overrides
  create_infra_overrides = true

  # Override values
  load_balancer          = "prod-api-alb-12345"
  prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/prod-api-alb/abc123/def456"
  prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/prod-api-alb/abc123/def456/ghi789"

  # Default values (used if specific values not provided)
  default_load_balancer          = "default-platform-alb"
  default_prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-alb/abc123/def456"
  default_prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/default-alb/abc123/def456/ghi789"
}
```

### Multiple Environments Example

To create infrastructure for multiple environments, instantiate the module multiple times:

```hcl
# Development infrastructure (identifier: dev_infrastructure)
module "dev_infrastructure" {
  source = "./infrastructure"

  org_id              = "default"
  project_id          = "platform_engineering"
  environment_id      = "dev"
  infrastructure_name = "Dev Infrastructure"

  aws_connector_ref = module.aws_connector.aws_connector_identifier
  cluster           = "dev-ecs-cluster"
  load_balancer     = "dev-alb"
}

# Production infrastructure (identifier: prod_infrastructure)
module "prod_infrastructure" {
  source = "./infrastructure"

  org_id              = "default"
  project_id          = "platform_engineering"
  environment_id      = "prod"
  infrastructure_name = "Prod Infrastructure"

  aws_connector_ref = module.aws_connector.aws_connector_identifier
  cluster           = "prod-ecs-cluster"
  load_balancer     = "prod-alb"
}
```

## Identifier Derivation

The infrastructure identifier is automatically derived from `infrastructure_name`:
- Converted to lowercase
- Spaces replaced with underscores
- Special characters removed or replaced with underscores

**Examples:**
- `"Dev Infrastructure"` → `dev_infrastructure`
- `"Production-Main"` → `production_main`
- `"Stage ECS-1"` → `stage_ecs_1`

If no name is provided, defaults to `"<environment_id> Infrastructure"`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| environment_id | Existing environment identifier | string | - | yes |
| aws_connector_ref | AWS connector identifier | string | - | yes |
| aws_region | AWS region | string | "us-east-1" | no |
| cluster | ECS cluster name | string | "default" | no |
| infrastructure_name | Infrastructure name (identifier auto-derived) | string | `<env_id> Infrastructure` | no |
| create_infra_overrides | Create infrastructure overrides | bool | true | no |
| load_balancer | Load balancer for override | string | null | no |
| prod_listener | Listener ARN for override | string | null | no |
| prod_listener_rule_arn | Listener rule ARN for override | string | null | no |

**Important:** `environment_id` must reference an existing environment. This module does not create environments.

## Outputs

| Name | Description |
|------|-------------|
| infrastructure_id | Infrastructure definition resource ID |
| infrastructure_identifier | Infrastructure identifier |
| infrastructure_name | Infrastructure name |
| infra_override_id | Infrastructure override resource ID (if enabled) |
| environment_id | Environment identifier |
| org_id | Organization ID |
| project_id | Project ID |
