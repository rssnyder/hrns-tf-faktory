# Changelog

## Latest Changes

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

### Migration Example

**Before:**
```hcl
module "aws_connector" {
  source = "./aws-connector"
  
  cloud_connector_identifier = "aws_prod_oidc"  # Manual identifier
  cloud_connector_name       = "AWS Production OIDC"
  iam_role_arn              = "arn:aws:iam::123456789012:role/my-role"  # Can use default
  cloud_region              = "us-east-1"
}

module "infrastructure" {
  cloud_connector_ref = module.aws_connector.cloud_connector_identifier
  cloud_region        = "us-east-1"
}
```

**After:**
```hcl
module "aws_connector" {
  source = "./aws-connector"
  
  # Identifier auto-derived as: aws_production_oidc
  aws_connector_name = "AWS Production OIDC"
  iam_role_arn      = "arn:aws:iam::123456789012:role/my-role"  # Now required!
  aws_region        = "us-east-1"
}

module "infrastructure" {
  aws_connector_ref = module.aws_connector.aws_connector_identifier
  aws_region        = "us-east-1"
}
```

### Benefits

1. **Simplified Configuration**: No need to manually manage connector identifiers
2. **Consistency**: Identifier automatically matches naming convention
3. **Clearer Naming**: "aws" prefix makes it clear these are AWS-specific resources
4. **Required IAM Role**: Removes misleading default, forces explicit configuration
