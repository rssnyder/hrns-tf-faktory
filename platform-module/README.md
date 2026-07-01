# Platform Module

This module has been split into three focused sub-modules:

## Sub-modules

### 1. aws-connector
Creates an AWS OIDC connector for Harness to authenticate with AWS.

The connector identifier is automatically derived from the connector name.

**Resources:**
- `harness_platform_connector_aws` - AWS connector with OIDC authentication

**Key Outputs:**
- `aws_connector_id` - Resource ID
- `aws_connector_identifier` - Connector identifier for referencing

### 2. infrastructure
Creates a single Harness infrastructure definition and optional infrastructure-specific overrides for one existing environment.

**Note:** Does NOT create environments. Creates ONE infrastructure per module instance.

**Resources:**
- `harness_platform_infrastructure` - Single infrastructure definition
- `harness_platform_service_overrides_v2` - INFRA_GLOBAL_OVERRIDE (optional)

**Key Outputs:**
- `infrastructure_id` - Infrastructure definition resource ID
- `infrastructure_identifier` - Infrastructure identifier
- `infra_override_id` - Infrastructure override resource ID

### 3. service
Creates the Harness CD service with ECS task and service definitions.

The service identifier is automatically derived from the service name.

**Resources:**
- `harness_platform_service` - CD service with ECS manifests

**Key Outputs:**
- `service_id` - Service resource ID
- `service_identifier` - Service identifier (auto-derived)

## Usage Example

### Basic Example

```hcl
# 1. AWS Connector
module "aws_connector" {
  source = "./platform-module/aws-connector"

  org_id     = "default"
  project_id = "platform_engineering"

  aws_connector_name = "AWS Production"  # Identifier: aws_production
  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-oidc-role"
  aws_region         = "us-east-1"
}

# 2. Infrastructure (one per environment - assumes environment exists)
module "dev_infrastructure" {
  source = "./platform-module/infrastructure"

  org_id              = "default"
  project_id          = "platform_engineering"
  environment_id      = "dev"  # Must already exist
  infrastructure_name = "Dev Infrastructure"  # Identifier: dev_infrastructure

  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  cluster           = "dev-cluster"
}

module "prod_infrastructure" {
  source = "./platform-module/infrastructure"

  org_id              = "default"
  project_id          = "platform_engineering"
  environment_id      = "prod"  # Must already exist
  infrastructure_name = "Prod Infrastructure"  # Identifier: prod_infrastructure

  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
  cluster           = "prod-cluster"
}

# 3. Service
module "service" {
  source = "./platform-module/service"

  org_id     = "default"
  project_id = "platform_engineering"

  service_name = "Platform API"  # Identifier: platform_api

  manifest_store_type = "Github"
  git_connector_ref   = "github_connector"
  git_repo_name       = "platform-configs"
}
```

### Complete Example with All Features

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.32"
    }
  }
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_account_id
  platform_api_key = var.harness_api_key
}

locals {
  org_id     = "default"
  project_id = "platform_engineering"
  region     = "us-east-1"
}

# 1. Create AWS OIDC Connector
module "aws_connector" {
  source = "./platform-module/aws-connector"

  org_id     = local.org_id
  project_id = local.project_id

  aws_connector_name        = "AWS Production OIDC"  # Identifier: aws_production_oidc
  aws_connector_description = "Production AWS connector using OIDC"
  aws_connector_tags        = ["env:production", "managed-by:terraform"]

  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-prod-oidc-role"
  aws_region         = local.region
  delegate_selectors = ["prod-delegate"]

  execute_on_delegate = true
  fixed_backoff       = 5000
  retry_count         = 3
}

# 2. Create Infrastructure Definitions (one per environment)
module "dev_infrastructure" {
  source = "./platform-module/infrastructure"

  org_id              = local.org_id
  project_id          = local.project_id
  environment_id      = "dev"  # Must already exist
  infrastructure_name = "Dev API Infrastructure"  # Identifier: dev_api_infrastructure

  aws_connector_ref              = module.aws_connector.aws_connector_identifier
  aws_region                     = local.region
  deployment_type                = "ECS"
  cluster                        = "dev-ecs-cluster"
  allow_simultaneous_deployments = false

  tags = {
    managed_by = "terraform"
    env        = "dev"
  }

  # Enable infrastructure overrides
  create_infra_overrides = true
  load_balancer          = "dev-api-alb-12345"
  prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/dev-api-alb/abc123/def456"
  prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/dev-api-alb/abc123/def456/ghi789"

  # Default values
  default_load_balancer          = "default-platform-alb"
  default_prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-alb/abc123/def456"
  default_prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/default-alb/abc123/def456/ghi789"
}

module "prod_infrastructure" {
  source = "./platform-module/infrastructure"

  org_id              = local.org_id
  project_id          = local.project_id
  environment_id      = "prod"  # Must already exist
  infrastructure_name = "Production API Infrastructure"  # Identifier: production_api_infrastructure

  aws_connector_ref              = module.aws_connector.aws_connector_identifier
  aws_region                     = local.region
  deployment_type                = "ECS"
  cluster                        = "prod-ecs-cluster"
  allow_simultaneous_deployments = false

  tags = {
    managed_by = "terraform"
    env        = "production"
  }

  # Enable infrastructure overrides
  create_infra_overrides = true
  load_balancer          = "prod-api-alb-12345"
  prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/prod-api-alb/abc123/def456"
  prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/prod-api-alb/abc123/def456/ghi789"

  # Default values
  default_load_balancer          = "default-platform-alb"
  default_prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-alb/abc123/def456"
  default_prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/default-alb/abc123/def456/ghi789"
}

# 3. Create Service
module "service" {
  source = "./platform-module/service"

  org_id     = local.org_id
  project_id = local.project_id

  service_name        = "Platform API Service"  # Identifier: platform_api_service
  service_description = "Main API service for platform features"
  deployment_type     = "ECS"

  manifest_store_type              = "Github"
  git_connector_ref                = "shared_services_github"
  git_repo_name                    = "platform-ecs-configs"
  git_branch                       = "main"
  task_definition_manifest_path    = "manifests/api/taskdef.json"
  service_definition_manifest_path = "manifests/api/service.json"
}

# Outputs
output "connector_id" {
  description = "AWS connector identifier"
  value       = module.aws_connector.aws_connector_identifier
}

output "dev_infrastructure_id" {
  description = "Dev infrastructure identifier"
  value       = module.dev_infrastructure.infrastructure_identifier
}

output "prod_infrastructure_id" {
  description = "Prod infrastructure identifier"
  value       = module.prod_infrastructure.infrastructure_identifier
}

output "service_id" {
  description = "Service identifier"
  value       = module.service.service_identifier
}
```

## Migration from Monolithic Module

The original module has been preserved in the parent directory files. To migrate:

1. Replace the single module call with three separate module calls (as shown above)
2. **Important:** The infrastructure module no longer creates environments - only infrastructure definitions
3. Environment identifiers passed to `infrastructure_configs` must already exist in Harness
4. Infrastructure overrides now live in the `infrastructure` module (not `service`)

## Dependencies

- `infrastructure` depends on `aws-connector` (needs connector reference) and existing environments
- `service` is independent - no dependencies on other modules
