# Module Split Summary

The platform module has been successfully split into three focused sub-modules.

## New Structure

```
platform-module/
├── aws-connector/       # AWS OIDC connector
├── infrastructure/      # Infrastructure definitions and overrides (NO environment creation)
├── service/            # CD service with manifests
└── [original files]    # Preserved for reference
```

## Key Changes

### 1. **aws-connector** - AWS OIDC Connector
- **Resources**: `harness_platform_connector_aws`
- **Purpose**: Create AWS OIDC connector
- **Identifier**: Automatically derived from connector name
- **Outputs**: `aws_connector_identifier` (used by infrastructure module)

### 2. **infrastructure** - Infrastructure Definitions and Overrides Only
- **Resources**:
  - `harness_platform_infrastructure` 
  - `harness_platform_service_overrides_v2` (INFRA_GLOBAL_OVERRIDE)
- **Purpose**: Create infrastructure definitions and infrastructure-specific overrides
- **⚠️ DOES NOT CREATE ENVIRONMENTS**: Environment identifiers must already exist
- **Key Change**: Infrastructure overrides moved here from service module
- **Inputs**: Requires `aws_connector_ref` from aws-connector and existing environment identifiers
- **Outputs**: `infrastructure_identifiers`, `infra_override_ids`

### 3. **service** - CD Service
- **Resources**: `harness_platform_service`
- **Purpose**: Create Harness CD service with ECS manifests
- **Key Change**: No longer manages infrastructure overrides
- **Independent**: No dependencies on other modules

## What Moved Where

| Resource/Feature | Old Location | New Location | Notes |
|-----------------|--------------|--------------|-------|
| AWS Connector | Monolithic | `aws-connector/` | - |
| **Environments** | **Monolithic** | **REMOVED** | **Module no longer creates environments** |
| Infrastructure Definitions | Monolithic | `infrastructure/` | Now takes env IDs as input |
| **Infrastructure Overrides** | **service-overrides/** | **infrastructure/** | Moved to infra module |
| CD Service | Monolithic | `service/` | - |

## Migration Guide

### Before (Monolithic)
```hcl
module "platform" {
  source = "./platform-module"
  
  create_cloud_connector = true
  create_cd_stack        = true
  create_infra_overrides = true
  
  environments = {
    dev = {
      name = "Dev"
      type = "PreProduction"
    }
  }
}
```

### After (Split Modules)
```hcl
# 1. AWS Connector
module "aws_connector" {
  source = "./platform-module/aws-connector"
  
  org_id     = "default"
  project_id = "platform_engineering"
  
  aws_connector_name = "AWS Production"  # Identifier: aws_production
  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-role"
}

# 2. Infrastructure (environment must already exist!)
module "infrastructure" {
  source = "./platform-module/infrastructure"
  
  org_id     = "default"
  project_id = "platform_engineering"
  
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  
  create_infra_overrides = true
  
  # Keys MUST match existing environment identifiers
  infrastructure_configs = {
    dev = {
      cluster       = "dev-cluster"
      load_balancer = "dev-alb"  # Override config
    }
  }
}

# 3. Service
module "service" {
  source = "./platform-module/service"
  
  org_id     = "default"
  project_id = "platform_engineering"
  
  service_identifier = "my_service"
  
  manifest_store_type = "Github"
  git_connector_ref   = "github_connector"
  git_repo_name       = "my-repo"
}
```

## Important Breaking Changes

### ⚠️ Infrastructure Module No Longer Creates Environments

**Before:** The module created both environments and infrastructure definitions.

**After:** The infrastructure module ONLY creates infrastructure definitions. You must:
1. Create environments separately (via UI, API, or separate Terraform resource)
2. Pass existing environment identifiers to `infrastructure_configs`

**Example:**
```hcl
# Create environments separately
resource "harness_platform_environment" "dev" {
  identifier = "dev"
  name       = "Development"
  org_id     = "default"
  project_id = "platform_engineering"
  type       = "PreProduction"
}

# Then reference in infrastructure module
module "infrastructure" {
  source = "./platform-module/infrastructure"
  
  infrastructure_configs = {
    dev = {  # Must match harness_platform_environment.dev.identifier
      cluster = "dev-cluster"
    }
  }
}
```

### Variable Changes

| Old Variable | New Variable | Module | Notes |
|--------------|--------------|--------|-------|
| `cloud_connector_*` | `aws_connector_*` | `aws-connector` | Renamed for clarity |
| `cloud_connector_identifier` | **REMOVED** | `aws-connector` | Now auto-derived from name |
| `cloud_region` | `aws_region` | Both modules | Renamed for clarity |
| `iam_role_arn` default | **REMOVED** | `aws-connector` | Now required, no default |
| `environments` | `infrastructure_configs` | `infrastructure` | No longer includes `name` and `type` fields |
| `environments[].name` | **REMOVED** | - | Environments must exist |
| `environments[].type` | **REMOVED** | - | Environments must exist |

## Important Notes

1. **Infrastructure module requires existing environments** - Keys in `infrastructure_configs` must match existing environment identifiers
2. **Infrastructure overrides are now in the infrastructure module** - This makes logical sense as they're infrastructure-specific variables
3. The `service` module is now completely independent - it only creates the service definition
4. Override variables (`load_balancer`, `prod_listener`, `prod_listener_rule_arn`) are now part of `infrastructure_configs`
5. The service module no longer needs `infrastructure_identifiers` or `environments` variables

## Testing the Split

Each sub-module can be tested independently:

```bash
# Test aws-connector
cd aws-connector && terraform init && terraform plan

# Test infrastructure (requires existing environments!)
cd infrastructure && terraform init && terraform plan

# Test service
cd service && terraform init && terraform plan
```
