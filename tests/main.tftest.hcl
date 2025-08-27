mock_provider "mittwald" {
  override_during = plan

  override_resource {
    target = mittwald_email_outbox.directus
    values = {
      name     = "directus-outbox"
      password = "very secure"
    }
  }

  override_resource {
    target = mittwald_mysql_database.directus
    values = {
      hostname = "mysql-XXXXXX.pg-s-YYYYYY.db.project.host"
    }
  }

  override_resource {
    target = mittwald_redis_database.directus
    values = {
      hostname = "redis-XXXXXX.pg-s-YYYYYY.db.project.host"
    }
  }
}

mock_provider "random" {
  override_during = plan
  override_resource {
    target = random_password.directus_email_outbox
    values = {
      result = "very secure"
    }
  }
}

variables {
  project_id       = "test-project"
  admin_email      = "test@example.com"
  admin_password   = "test-password-123"
  email_from       = "noreply@example.com"
  directus_version = "11"
}

run "basic_module_validation" {
  command = plan

  assert {
    condition     = random_password.directus_database.length == 24
    error_message = "Database password should be 24 characters long"
  }

  assert {
    condition     = random_string.directus_secret.length == 32
    error_message = "Directus secret should be 32 characters long"
  }

  assert {
    condition     = mittwald_mysql_database.directus.version == "8.0"
    error_message = "MySQL database version should be 8.0"
  }

  assert {
    condition     = mittwald_redis_database.directus.version == "7.2"
    error_message = "Redis database version should be 7.2"
  }

  assert {
    condition     = mittwald_mysql_database.directus.character_settings.character_set == "utf8mb4"
    error_message = "MySQL character set should be utf8mb4"
  }

  assert {
    condition     = mittwald_mysql_database.directus.character_settings.collation == "utf8mb4_unicode_ci"
    error_message = "MySQL collation should be utf8mb4_unicode_ci"
  }

  assert {
    condition     = mittwald_redis_database.directus.configuration.max_memory_mb == 128
    error_message = "Redis max memory should be 128MB by default"
  }

  assert {
    condition     = mittwald_redis_database.directus.configuration.persistent == false
    error_message = "Redis should not be persistent by default"
  }

  assert {
    condition     = mittwald_container_stack.directus.default_stack == true
    error_message = "Container stack should be default stack"
  }

  assert {
    condition     = contains(keys(mittwald_container_stack.directus.containers), "directus")
    error_message = "Container stack should contain directus container"
  }

  assert {
    condition     = one(mittwald_container_stack.directus.containers["directus"].ports).container_port == 8055
    error_message = "Container port should be 8055"
  }

  assert {
    condition     = one(mittwald_container_stack.directus.containers["directus"].ports).public_port == 8055
    error_message = "Public port should be 8055"
  }

  assert {
    condition     = contains(keys(mittwald_container_stack.directus.volumes), "directus-uploads")
    error_message = "Volumes should contain directus-uploads"
  }

  assert {
    condition     = contains(keys(mittwald_container_stack.directus.volumes), "directus-extensions")
    error_message = "Volumes should contain directus-extensions"
  }

  assert {
    condition     = contains(keys(mittwald_container_stack.directus.volumes), "directus-templates")
    error_message = "Volumes should contain directus-templates"
  }

  assert {
    condition     = random_password.directus_email_outbox.length == 16
    error_message = "Email outbox password should be 16 characters long"
  }

  assert {
    condition     = random_password.directus_email_outbox.special == true
    error_message = "Email outbox password should include special characters"
  }

  assert {
    condition     = mittwald_email_outbox.directus.project_id == var.project_id
    error_message = "Email outbox project ID should match input variable"
  }

  assert {
    condition     = mittwald_email_outbox.directus.description == "Directus Email Outbox"
    error_message = "Email outbox description should be 'Directus Email Outbox'"
  }

  assert {
    condition     = mittwald_email_outbox.directus.password == "very secure"
    error_message = "Email outbox password should be configured"
  }
}

run "environment_variables_validation" {
  command = plan

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["ADMIN_EMAIL"] == var.admin_email
    error_message = "ADMIN_EMAIL environment variable should match input variable"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["ADMIN_PASSWORD"] == var.admin_password
    error_message = "ADMIN_PASSWORD environment variable should match input variable"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["DB_CLIENT"] == "mysql"
    error_message = "DB_CLIENT should be mysql"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["DB_PORT"] == "3306"
    error_message = "DB_PORT should be 3306"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["DB_HOST"] == "mysql-XXXXXX.pg-s-YYYYYY.db.project.host"
    error_message = "DB_HOST should use mocked MySQL hostname"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["CACHE_ENABLED"] == "true"
    error_message = "CACHE_ENABLED should be true"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["CACHE_STORE"] == "redis"
    error_message = "CACHE_STORE should be redis"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["REDIS"] == "redis://redis-XXXXXX.pg-s-YYYYYY.db.project.host:6379"
    error_message = "REDIS should use mocked Redis hostname"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_TRANSPORT"] == "smtp"
    error_message = "EMAIL_TRANSPORT should be smtp"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_SMTP_HOST"] == "mail.agenturserver.de"
    error_message = "EMAIL_SMTP_HOST should be mail.agenturserver.de"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_FROM"] == var.email_from
    error_message = "EMAIL_FROM should match input variable"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_SMTP_USER"] == mittwald_email_outbox.directus.name
    error_message = "EMAIL_SMTP_USER should use email outbox name"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_SMTP_PASSWORD"] != null
    error_message = "EMAIL_SMTP_PASSWORD should be configured"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_SMTP_PORT"] == "587"
    error_message = "EMAIL_SMTP_PORT should be 587"
  }

  assert {
    condition     = mittwald_container_stack.directus.containers["directus"].environment["EMAIL_SMTP_SECURE"] == "1"
    error_message = "EMAIL_SMTP_SECURE should be 1"
  }
}

run "custom_redis_memory_validation" {
  command = plan

  variables {
    project_id          = "test-project"
    admin_email         = "test@example.com"
    admin_password      = "test-password-123"
    email_from          = "noreply@example.com"
    directus_version    = "11"
    redis_max_memory_mb = 256
  }

  assert {
    condition     = mittwald_redis_database.directus.configuration.max_memory_mb == 256
    error_message = "Redis max memory should match custom value"
  }
}

run "output_validation" {
  command = plan

  assert {
    condition     = output.container_url == "http://directus:8055"
    error_message = "Container URL output should be correctly formatted"
  }
}