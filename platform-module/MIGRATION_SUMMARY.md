# Module Split Summary

The platform module has been successfully split into three focused sub-modules.

## New Structure

```
platform-module/
├── aws-connector/       # AWS OIDC connector
├── infrastructure/      # Environments, infra definitions, and overrides
├── service/            # CD service with manifests
└── [original files]    # Preserved for reference
```

## Key Changes

### 1. **aws-connector** - AWS OIDC Connector
- **Resources**: `harness_platform_connector_aws`
- **Purpose**: Create AWS OIDC connector
- **Outputs**: `cloud_connector_identifier` (used by infrastructure module)

### 2. **infrastructure** - Environments, Infrastructure, and Overrides
- **Resources**:
  - `harness_platform_environment`
  - `harness_platform_infrastructure` 
  - `harness_platform_service_overrides_v2` (INFRA_GLOBAL_OVERRIDE)
- **Purpose**: Create environments, infrastructure definitions, and infrastructure-specific overrides
- **Key Change**: Infrastructure overrides moved here from service module
- **Inputs**: Requires `cloud_connector_ref` from aws-connector
- **Outputs**: `infrastructure_identifiers`, `infra_override_ids`

### 3. **service** - CD Service
- **Resources**: `harness_platform_service`
- **Purpose**: Create Harness CD service with ECS manifests
- **Key Change**: No longer manages infrastructure overrides
- **Independent**: No dependencies on other modules

## What Moved Where

| Resource/Feature | Old Location | New Location |
|-----------------|--------------|--------------|
| AWS Connector | Monolithic | `aws-connector/` |
| Environments | Monolithic | `infrastructure/` |
| Infrastructure Definitions | Monolithic | `infrastructure/` |
| **Infrastructure Overrides** | **service-overrides/** | **infrastructure/** |
| CD Service | Monolithic | `service/` |

## Migration Guide

### Before (Monolithic)
```hcl
module "platform" {
  source = "./platform-module"
  
  create_cloud_connector = true
  create_cd_stack        = true
  create_infra_overrides = true
  
  # All variables in one place
}
```

### After (Split Modules)
```hcl
# 1. AWS Connector
module "aws_connector" {
  source = "./platform-module/aws-connector"
  
  org_id     = "default"
  project_id = "platform_engineering"
  
  iam_role_arn = "arn:aws:iam::123456789012:role/harness-role"
}

# 2. Infrastructure (includes overrides!)
module "infrastructure" {
  source = "./platform-module/infrastructure"
  
  org_id     = "default"
  project_id = "platform_engineering"
  
  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  
  create_infra_overrides = true  # Moved here!
  
  environments = {
    dev = {
      name          = "Development"
      type          = "PreProduction"
      cluster       = "dev-cluster"
      load_balancer = "dev-alb"  # Override config here!
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

## Important Notes

1. **Infrastructure overrides are now in the infrastructure module** - This makes logical sense as they're infrastructure-specific variables
2. The `service` module is now completely independent - it only creates the service definition
3. Override variables (`load_balancer`, `prod_listener`, `prod_listener_rule_arn`) are now part of the `environments` object in the infrastructure module
4. The infrastructure module outputs `infra_override_ids` if overrides are enabled
5. The service module no longer needs `infrastructure_identifiers` or `environments` variables

## Testing the Split

Each sub-module can be tested independently:

```bash
# Test aws-connector
cd aws-connector && terraform init && terraform plan

# Test infrastructure
cd infrastructure && terraform init && terraform plan

# Test service
cd service && terraform init && terraform plan
```
