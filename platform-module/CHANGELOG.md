# Changelog

## Latest Changes

### All Modules - Identifier Auto-Derivation

All three modules now auto-derive identifiers from names for consistency:

| Module | Name Variable | Derived Identifier |
|--------|--------------|-------------------|
| `aws-connector` | `aws_connector_name` → | `aws_connector_identifier` |
| `infrastructure` | `infrastructure_name` → | `infrastructure_identifier` |
| `service` | `service_name` → | `service_identifier` |

**Service Module Changes:**
- **REMOVED**: `service_identifier` variable (now auto-derived)
- **UPDATED**: `service_name` now required (was optional with default)
- **Derivation**: Lowercase + replace spaces with `_` + remove special chars
- **Example**: "Platform API Service" → `platform_api_service`

### Infrastructure Module - Single Instance Per Environment

#### Breaking Change: One Infrastructure Per Module Instance

The infrastructure module now creates **ONE infrastructure definition** per module instance, rather than creating multiple infrastructure definitions in a loop.

**Before (Multi-Instance):**
```hcl
module "infrastructure" {
  source = "./infrastructure"
  
  infrastructure_configs = {
    dev = { cluster = "dev-cluster" }
    prod = { cluster = "prod-cluster" }
  }
}
```

**After (Single-Instance):**
```hcl
# One module call per environment
module "dev_infrastructure" {
  source = "./infrastructure"
  
  environment_id = "dev"
  cluster        = "dev-cluster"
}

module "prod_infrastructure" {
  source = "./infrastructure"
  
  environment_id = "prod"
  cluster        = "prod-cluster"
}
```

#### Variable Changes

**Removed:**
- `infrastructure_configs` (map of environments)
- `cluster_overrides` (map)
- `default_cluster` (string)
- `infrastructure_identifier_suffix` (string)
- `infrastructure_identifier` (string) - **Now auto-derived from name**

**Added:**
- `environment_id` (string) - **Required** - Single environment identifier
- `cluster` (string) - Single cluster name
- `infrastructure_name` (string, optional) - Name (identifier auto-derived), defaults to `<env_id> Infrastructure`
- `load_balancer` (string, optional) - Direct override value
- `prod_listener` (string, optional) - Direct override value  
- `prod_listener_rule_arn` (string, optional) - Direct override value

#### Identifier Auto-Derivation

Just like the AWS connector, the infrastructure identifier is now automatically derived from `infrastructure_name`:
- Converts to lowercase
- Replaces spaces with underscores  
- Removes/replaces special characters
- Example: "Dev Infrastructure" → `dev_infrastructure`

#### Output Changes

**Removed:**
- `infrastructure_ids` (map)
- `infrastructure_identifiers` (map)
- `infra_override_ids` (map)

**Added:**
- `infrastructure_id` (string) - Single infrastructure ID
- `infrastructure_identifier` (string) - Single infrastructure identifier
- `infrastructure_name` (string) - Infrastructure name
- `infra_override_id` (string) - Single override ID
- `environment_id` (string) - Echo of input environment_id

#### Benefits

1. **Simpler Logic**: No complex map iterations
2. **Better Isolation**: Each infrastructure is independently managed
3. **Clearer Dependencies**: Explicit module instances make dependencies obvious
4. **Standard Terraform Pattern**: One resource per module instance is idiomatic
5. **Easier to Reason About**: No hidden loops or complex conditionals

---

## Previous Changes

### AWS Connector Module Updates

#### Identifier Auto-Derivation
- **REMOVED**: `cloud_connector_identifier` variable
- **NEW**: Identifier is now automatically derived from `aws_connector_name`
  - Converts to lowercase
  - Replaces spaces with underscores
  - Removes/replaces special characters
  - Example: "AWS Production" → "aws_production"

#### Variable Renaming (cloud → aws)
- `cloud_connector_identifier` → **REMOVED** (auto-derived)
- `cloud_connector_name` → `aws_connector_name` (now required)
- `cloud_connector_description` → `aws_connector_description`
- `cloud_connector_tags` → `aws_connector_tags`
- `cloud_region` → `aws_region`

#### Output Renaming
- `cloud_connector_id` → `aws_connector_id`
- `cloud_connector_identifier` → `aws_connector_identifier`

#### Removed Defaults
- **REMOVED**: Default value for `iam_role_arn`
  - Was: `arn:aws:iam::568258498023:role/harness-demo-oidc-role`
  - Now: Must be explicitly provided (required parameter)

### Infrastructure Module Updates

#### Variable Renaming
- `cloud_connector_ref` → `aws_connector_ref`
- `cloud_region` → `aws_region`
