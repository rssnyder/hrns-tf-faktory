# Service Sub-module

Creates the Harness CD service with ECS task and service definitions.

The service identifier is automatically derived from the service name.

## Resources

- `harness_platform_service` - CD service with ECS task/service definitions

## Usage

### Basic Example with Github Manifests

```hcl
module "service" {
  source = "./service"

  org_id     = "default"
  project_id = "platform_engineering"

  # Service configuration (identifier: platform_api_service)
  service_name = "Platform API Service"

  # Github manifest configuration
  manifest_store_type = "Github"
  git_connector_ref   = "github_connector"
  git_repo_name       = "platform-configs"
  git_branch          = "main"
}
```

### Complete Example with Custom Manifests

```hcl
module "service" {
  source = "./service"

  # Required
  org_id     = "default"
  project_id = "platform_engineering"

  # Service configuration (identifier: platform_api_service)
  service_name        = "Platform API Service"
  service_description = "Main API service for platform features"
  deployment_type     = "ECS"

  # Tags
  tags = {
    service = "api"
    tier    = "backend"
  }

  default_tags = {
    team = "platform-engineering"
  }

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
module "service" {
  source = "./service"

  org_id     = "default"
  project_id = "platform_engineering"

  service_name = "Platform Worker Service"  # Identifier: platform_worker_service

  # Use Harness File Store instead of Github
  manifest_store_type              = "Harness"
  task_definition_manifest_path    = "/platform/ecs/worker/taskdef.json"
  service_definition_manifest_path = "/platform/ecs/worker/service.json"
}
```

## Identifier Derivation

The service identifier is automatically derived from `service_name`:
- Converted to lowercase
- Spaces replaced with underscores
- Special characters removed or replaced with underscores

**Examples:**
- `"Platform API Service"` → `platform_api_service`
- `"Worker-Service"` → `worker_service`
- `"My Service v2"` → `my_service_v2`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | Harness organization identifier | string | - | yes |
| project_id | Harness project identifier | string | - | yes |
| service_name | Service name (identifier auto-derived) | string | - | yes |
| service_description | Service description | string | "Harness service managed by Terraform" | no |
| manifest_store_type | Manifest store type (Github or Harness) | string | "Github" | no |
| git_connector_ref | Git connector identifier (required if Github) | string | null | conditional |
| git_repo_name | Git repository name (required if Github) | string | null | conditional |

## Outputs

| Name | Description |
|------|-------------|
| service_id | Service resource ID |
| service_identifier | Service identifier (derived from name) |
| service_name | Service name |
| org_id | Organization ID |
| project_id | Project ID |
