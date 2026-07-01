# Platform Module

This module has been split into three focused sub-modules:

## Sub-modules

### 1. aws-connector
Creates an AWS OIDC connector for Harness to authenticate with AWS.

**Resources:**
- `harness_platform_connector_aws` - AWS connector with OIDC authentication

**Key Outputs:**
- `cloud_connector_id` - Resource ID
- `cloud_connector_identifier` - Connector identifier for referencing

### 2. infrastructure
Creates Harness environments and infrastructure definitions.

**Resources:**
- `harness_platform_environment` - CD environments (dev, testing, stage, prod)
- `harness_platform_infrastructure` - Infrastructure definitions per environment

**Key Outputs:**
- `environment_ids` - Environment resource IDs
- `infrastructure_ids` - Infrastructure definition resource IDs
- `infrastructure_identifiers` - Infrastructure identifiers (needed by service-overrides)

### 3. service-overrides
Creates the Harness service and infrastructure-specific overrides.

**Resources:**
- `harness_platform_service` - CD service with ECS manifests
- `harness_platform_service_overrides_v2` - INFRA_GLOBAL_OVERRIDE per environment

**Key Outputs:**
- `service_id` - Service resource ID
- `infra_override_ids` - Override resource IDs

## Usage Example

### Basic Example

```hcl
# 1. AWS Connector
module "aws_connector" {
  source = "./platform-module/aws-connector"

  org_id     = "default"
  project_id = "platform_engineering"

  cloud_connector_identifier = "aws_oidc"
  iam_role_arn              = "arn:aws:iam::123456789012:role/harness-oidc-role"
  cloud_region              = "us-east-1"
}

# 2. Infrastructure
module "infrastructure" {
  source = "./platform-module/infrastructure"

  org_id     = "default"
  project_id = "platform_engineering"

  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  cloud_region        = "us-east-1"

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

# 3. Service and Overrides
module "service_overrides" {
  source = "./platform-module/service-overrides"

  org_id     = "default"
  project_id = "platform_engineering"

  service_identifier = "platform_api"
  service_name       = "Platform API"

  infrastructure_identifiers = module.infrastructure.infrastructure_identifiers

  environments = {
    dev = {
      load_balancer = "dev-alb"
    }
    prod = {
      load_balancer = "prod-alb"
    }
  }

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

  cloud_connector_identifier  = "aws_production_oidc"
  cloud_connector_name        = "AWS Production OIDC"
  cloud_connector_description = "Production AWS connector using OIDC"
  cloud_connector_tags        = ["env:production", "managed-by:terraform"]

  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-prod-oidc-role"
  cloud_region       = local.region
  delegate_selectors = ["prod-delegate"]

  execute_on_delegate = true
  fixed_backoff       = 5000
  retry_count         = 3
}

# 2. Create Environments and Infrastructure Definitions
module "infrastructure" {
  source = "./platform-module/infrastructure"

  org_id     = local.org_id
  project_id = local.project_id

  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  cloud_region        = local.region
  deployment_type     = "ECS"

  default_cluster                = "default-ecs-cluster"
  allow_simultaneous_deployments = false

  tags = {
    managed_by = "terraform"
    project    = "platform-api"
  }

  cluster_overrides = {
    prod = "production-ecs-cluster"
  }

  environments = {
    dev = {
      name                      = "Development"
      type                      = "PreProduction"
      cluster                   = "dev-ecs-cluster"
      infrastructure_identifier = "dev_infra"
    }
    testing = {
      name    = "Testing"
      type    = "PreProduction"
      cluster = "test-ecs-cluster"
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

# 3. Create Service with Infrastructure Overrides
module "service_overrides" {
  source = "./platform-module/service-overrides"

  org_id     = local.org_id
  project_id = local.project_id

  service_identifier  = "platform_api_service"
  service_name        = "Platform API Service"
  service_description = "Main API service for platform features"
  deployment_type     = "ECS"

  infrastructure_identifiers = module.infrastructure.infrastructure_identifiers
  create_infra_overrides     = true

  environments = {
    dev = {
      load_balancer          = "dev-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/dev-api-alb/abc123/def456"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/dev-api-alb/abc123/def456/ghi789"
    }
    testing = {
      load_balancer = "test-api-alb-12345"
    }
    stage = {
      load_balancer = "stage-api-alb-12345"
    }
    prod = {
      load_balancer          = "prod-api-alb-12345"
      prod_listener          = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/prod-api-alb/abc123/def456"
      prod_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener-rule/app/prod-api-alb/abc123/def456/ghi789"
    }
  }

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
  value       = module.aws_connector.cloud_connector_identifier
}

output "environment_ids" {
  description = "All environment identifiers"
  value       = module.infrastructure.environment_identifiers
}

output "service_id" {
  description = "Service identifier"
  value       = module.service_overrides.service_identifier
}
```

## Migration from Monolithic Module

The original module has been preserved in the parent directory files. To migrate:

1. Replace the single module call with three separate module calls (as shown above)
2. Update any references to outputs to use the appropriate sub-module output
3. Review and adjust variables - some have moved between modules

## Dependencies

- `infrastructure` depends on `aws-connector` (needs connector reference)
- `service-overrides` depends on `infrastructure` (needs infrastructure identifiers for overrides)
