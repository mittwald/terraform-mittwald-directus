# Simple Example

This example demonstrates how to use the `mittwald/directus` Terraform module to deploy Directus on Mittwald's infrastructure.

## Directus Deployment

The Directus CMS application is deployed in a container using the Terraform module.

```hcl
module "directus" {
  source  = "mittwald/directus/mittwald"
  version = "1.0.0"

  directus_version    = "latest"
  project_id          = "example_project_id"
  redis_max_memory_mb = 128
  admin_email         = "admin@example.com"
  admin_password      = random_password.admin_password.result
}
```

## Dynamic Admin Password

A secure admin password is generated dynamically using the `random_password` resource.

```hcl
resource "random_password" "admin_password" {
  length           = 16
  special          = true
}
```

## Domain Connection

The Directus container is connected to a custom domain using the `mittwald_virtualhost` resource.

```hcl
resource "mittwald_virtualhost" "directus" {
  hostname   = "example.com"
  project_id = "example_project_id"

  paths = {
    "/" = {
      container = {
        container_id = module.directus.container_id
        port         = "8055/tcp"
      }
    }
  }
}
```
