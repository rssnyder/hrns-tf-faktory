# AWS Connector Sub-module

Creates an AWS OIDC connector for Harness to authenticate with AWS.

## Resources

- `harness_platform_connector_aws` - AWS connector with OIDC authentication

## Usage

### Basic Example

```hcl
module "aws_connector" {
  source = "./aws-connector"

  org_id     = "myorg"
  project_id = "myproject"

  cloud_connector_identifier = "aws_oidc"
  cloud_connector_name       = "AWS OIDC Connector"
  iam_role_arn              = "arn:aws:iam::123456789012:role/harness-oidc-role"
  cloud_region              = "us-east-1"
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
  cloud_connector_identifier = "aws_production_oidc"
  cloud_connector_name       = "AWS Production OIDC Connector"
  cloud_connector_description = "Production AWS connector using OIDC for secure authentication"
  cloud_connector_tags       = ["env:production", "team:platform"]

  # AWS configuration
  iam_role_arn       = "arn:aws:iam::123456789012:role/harness-prod-oidc-role"
  cloud_region       = "us-east-1"
  delegate_selectors = ["prod-delegate", "us-east-1-delegate"]

  # Execution options
  execute_on_delegate = true

  # Retry configuration
  fixed_backoff = 5000
  retry_count   = 3
}

# Output the connector identifier for use in other modules
output "connector_id" {
  value = module.aws_connector.cloud_connector_identifier
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| cloud_connector_identifier | Connector identifier | string | "cloud_connector" | no |
| iam_role_arn | AWS IAM role ARN for OIDC | string | - | yes |
| cloud_region | AWS region | string | "us-east-1" | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud_connector_id | Cloud connector resource ID |
| cloud_connector_identifier | Cloud connector identifier (use this in infrastructure module) |
| org_id | Organization ID |
| project_id | Project ID |
