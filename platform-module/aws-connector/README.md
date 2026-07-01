# AWS Connector Sub-module

Creates an AWS OIDC connector for Harness to authenticate with AWS.

The connector identifier is automatically derived from the connector name by converting to lowercase and replacing special characters with underscores.

## Resources

- `harness_platform_connector_aws` - AWS connector with OIDC authentication

## Usage

### Basic Example

```hcl
module "aws_connector" {
  source = "./aws-connector"

  org_id     = "default"
  project_id = "platform_engineering"

  aws_connector_name = "AWS Production"  # Identifier will be: aws_production
  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-oidc-role"
  aws_region         = "us-east-1"
}
```

### Complete Example with All Options

```hcl
module "aws_connector" {
  source = "./aws-connector"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # Connector configuration
  aws_connector_name        = "AWS Production OIDC"  # Identifier: aws_production_oidc
  aws_connector_description = "Production AWS connector using OIDC for secure authentication"
  aws_connector_tags        = ["env:production", "team:platform"]

  # AWS configuration
  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-prod-oidc-role"
  aws_region         = "us-east-1"
  delegate_selectors = ["prod-delegate", "us-east-1-delegate"]

  # Execution options
  execute_on_delegate = true

  # Retry configuration
  fixed_backoff = 5000
  retry_count   = 3
}

# Output the connector identifier for use in other modules
output "connector_id" {
  value = module.aws_connector.aws_connector_identifier
}
```

## Identifier Derivation

The connector identifier is automatically derived from `aws_connector_name`:
- Converted to lowercase
- Spaces replaced with underscores
- Special characters removed or replaced with underscores

**Examples:**
- `"AWS Production"` → `aws_production`
- `"AWS-DEV-OIDC"` → `aws_dev_oidc`
- `"My AWS Connector!"` → `my_aws_connector_`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| aws_connector_name | AWS connector display name | string | - | yes |
| iam_role_arn | AWS IAM role ARN for OIDC | string | - | yes |
| aws_region | AWS region | string | "us-east-1" | no |
| aws_connector_description | Connector description | string | "AWS connector using Harness OIDC authentication" | no |
| delegate_selectors | Delegate selectors | set(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| aws_connector_id | AWS connector resource ID |
| aws_connector_identifier | AWS connector identifier (use this in infrastructure module) |
| org_id | Organization ID |
| project_id | Project ID |
