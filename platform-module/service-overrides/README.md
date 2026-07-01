# Service and Overrides Sub-module

Creates the Harness CD service and infrastructure-specific overrides.

## Resources

- `harness_platform_service` - CD service with ECS task/service definitions
- `harness_platform_service_overrides_v2` - INFRA_GLOBAL_OVERRIDE per environment/infrastructure

## Usage

### Basic Example with Github Manifests

```hcl
module "service_overrides" {
  source = "./service-overrides"

  org_id     = "default"
  project_id = "platform_engineering"

  # Service configuration
  service_identifier = "platform_api"
  service_name       = "Platform API Service"

  # Link to infrastructure module
  infrastructure_identifiers = module.infrastructure.infrastructure_identifiers

  # Environment overrides
  environments = {
    dev = {
      load_balancer = "dev-platform-alb"
    }
    prod = {
      load_balancer = "prod-platform-alb"
    }
  }

  # Github manifest configuration
  manifest_store_type = "Github"
  git_connector_ref   = "github_connector"
  git_repo_name       = "platform-configs"
  git_branch          = "main"
}
```

### Complete Example with Infrastructure Overrides

```hcl
module "service_overrides" {
  source = "./service-overrides"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # Service configuration
  service_identifier  = "platform_api_service"
  service_name        = "Platform API Service"
  service_description = "Main API service for platform features"
  deployment_type     = "ECS"

  # Tags
  tags = {
    service = "api"
    tier    = "backend"
  }

  # Link to infrastructure module outputs
  infrastructure_identifiers = module.infrastructure.infrastructure_identifiers

  # Enable infrastructure overrides
  create_infra_overrides = true

  # Per-environment infrastructure overrides
  environments = {
    dev = {
      load_balancer          = "dev-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/dev-api-alb/abc123def456/ghi789jkl012"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/dev-api-alb/abc123def456/ghi789jkl012/mno345pqr678"
    }
    testing = {
      load_balancer          = "test-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/test-api-alb/abc123def456/ghi789jkl012"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/test-api-alb/abc123def456/ghi789jkl012/mno345pqr678"
    }
    stage = {
      load_balancer = "stage-api-alb-12345"
    }
    prod = {
      load_balancer          = "prod-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/prod-api-alb/abc123def456/ghi789jkl012"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/prod-api-alb/abc123def456/ghi789jkl012/mno345pqr678"
    }
  }

  # Default values for environments without explicit overrides
  default_load_balancer          = "default-platform-alb"
  default_prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-alb/default123/default456"
  default_prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/default-alb/default123/default456/default789"

  # Github manifest configuration
  manifest_store_type              = "Github"
  git_connector_ref                = "shared_services_github"
  git_repo_name                    = "platform-ecs-configs"
  git_branch                       = "main"
  task_definition_manifest_path    = "manifests/api/taskdef.json"
  service_definition_manifest_path = "manifests/api/service.json"

  # Manifest identifiers
  task_definition_manifest_identifier    = "api_task_definition"
  service_definition_manifest_identifier = "api_service_definition"
}
```

### Example with Harness File Store

```hcl
module "service_overrides" {
  source = "./service-overrides"

  org_id     = "default"
  project_id = "platform_engineering"

  service_identifier = "platform_worker"
  service_name       = "Platform Worker Service"

  infrastructure_identifiers = module.infrastructure.infrastructure_identifiers

  environments = {
    dev = {
      load_balancer = "dev-worker-alb"
    }
    prod = {
      load_balancer = "prod-worker-alb"
    }
  }

  # Use Harness File Store instead of Github
  manifest_store_type              = "Harness"
  task_definition_manifest_path    = "/platform/ecs/worker/taskdef.json"
  service_definition_manifest_path = "/platform/ecs/worker/service.json"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| service_identifier | Service identifier | string | "platform_service" | no |
| service_name | Service display name | string | "Platform Service" | no |
| infrastructure_identifiers | Infrastructure IDs from infrastructure module | map(string) | {} | yes (if overrides enabled) |
| environments | Environment override configurations | map(object) | null | yes (if overrides enabled) |
| manifest_store_type | Manifest store type (Github or Harness) | string | "Github" | no |

## Outputs

| Name | Description |
|------|-------------|
| service_id | Service resource ID |
| service_identifier | Service identifier |
| infra_override_ids | Override resource IDs per environment |
| org_id | Organization ID |
| project_id | Project ID |
