module "directus" {
  source  = "mittwald/directus/mittwald"
  version = "1.0.0"

  directus_version    = "latest"
  project_id          = "example_project_id"
  redis_max_memory_mb = 128
  admin_email         = "admin@example.com"
  admin_password      = random_password.admin_password.result
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
}

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
