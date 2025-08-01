terraform {
  required_providers {
    mittwald = {
      source  = "mittwald/mittwald"
      version = "~> 1.2.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

locals {
  container_name      = "directus"
  container_port      = 8055

  url = "http://${local.container_name}:${local.container_port}"
}

data "mittwald_container_image" "directus" {
  image = "directus/directus:${var.directus_version}"
}

resource "random_password" "directus_database" {
  length  = 24

  lower = true
  upper = true
  numeric = true
  special = true

  min_lower = 1
  min_upper = 1
  min_numeric = 1
  min_special = 1

  override_special = "#!~%^*_+-=?{}()<>|.,;"
}

resource "random_string" "directus_secret" {
  length  = 32
}

resource "mittwald_mysql_database" "directus" {
  project_id  = var.project_id
  version     = "8.0"
  description = "Directus CMS"

  character_settings = {
    character_set = "utf8mb4"
    collation     = "utf8mb4_unicode_ci"
  }

  user = {
    password            = random_password.directus_database.result
    access_level        = "full"
    external_access     = false
  }
}

resource "mittwald_redis_database" "directus" {
  project_id  = var.project_id
  version     = "7.2"
  description = "Directus Redis Cache"

  configuration = {
    persistent = false
    max_memory_mb = var.redis_max_memory_mb
    max_memory_policy = "allkeys-lru"
  }
}

resource "mittwald_container_stack" "directus" {
  project_id    = var.project_id
  default_stack = true

  containers = {
    (local.container_name) = {
      image       = data.mittwald_container_image.directus.image
      description = "Directus"
      ports = [
        {
          container_port = local.container_port
          public_port    = local.container_port
          protocol       = "tcp"
        }
      ]

      entrypoint = data.mittwald_container_image.directus.entrypoint
      command    = data.mittwald_container_image.directus.command

      environment = {
        ADMIN_EMAIL    = var.admin_email
        ADMIN_PASSWORD = var.admin_password

        SECRET         = random_string.directus_secret.result

        DB_CLIENT      = "mysql"
        DB_HOST        = mittwald_mysql_database.directus.hostname
        DB_PORT        = "3306"
        DB_DATABASE    = mittwald_mysql_database.directus.name
        DB_USER        = mittwald_mysql_database.directus.user.name
        DB_PASSWORD    = random_password.directus_database.result

        CACHE_ENABLED    = "true"
        CACHE_STORE      = "redis"
        CACHE_AUTO_PURGE = "true"
        REDIS            = "redis://${mittwald_redis_database.directus.hostname}:6379"
      }

      volumes = [
        {
          volume     = "${local.container_name}-uploads"
          mount_path = "/directus/uploads"
        },
        {
          volume     = "${local.container_name}-extensions"
          mount_path = "/directus/extensions"
        },
        {
          volume     = "${local.container_name}-templates"
          mount_path = "/directus/templates"
        }
      ]
    }
  }

  volumes = {
    ("${local.container_name}-uploads") = {},
    ("${local.container_name}-extensions") = {},
    ("${local.container_name}-templates") = {}
  }
}
