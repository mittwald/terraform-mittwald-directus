# mStudio Directus module

## Overview

This project uses Terraform to deploy [Directus](https://directus.io) on mittwald's infrastructure. It includes resources for MySQL and Redis databases, containerized Directus application, and necessary configurations.

## Features

- **Directus CMS**: Deploys the Directus application in a container.
- **MySQL Database**: Configures a MySQL database for Directus.
- **Redis Cache**: Sets up a Redis database for caching.
- **Random Secrets**: Generates secure random passwords and secrets.
- **Customizable**: Allows configuration of Directus version, project ID, Redis memory settings, and admin credentials.

## Prerequisites

- Terraform installed on your system.
- Access to mittwald's infrastructure.
- Valid project ID and admin credentials.

## Usage

1. Add the module to your Terraform configuration:
   ```hcl
   module "directus" {
     source  = "mittwald/directus/mittwald"
     version = "1.0.0"

     directus_version    = "latest"
     project_id          = "your_project_id"
     redis_max_memory_mb = 128
     admin_email         = "admin@example.com"
     admin_password      = "your_password"
   }
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Access Directus:
   From within your hosting environment (other containers or managed applications), you can connect to your Directus instance via the URL generated in the `locals` block (usually `http://directus:8055`).

   To make the application accessible via a custom domain, you need to connect a domain to the container. Use the `mittwald_virtualhost` resource and specify the `container_id` output variable from this module as the target container. For example:

   ```hcl
   resource "mittwald_virtualhost" "directus" {
     hostname = "test.example"
     project_id = "your_project_id"

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

## Project Structure

```
main.tf
outputs.tf
variables.tf
modules/
  directus/
    main.tf
    outputs.tf
    variables.tf
```
- **main.tf**: Defines the main resources for the project.
- **outputs.tf**: Specifies outputs for the Terraform configuration.
- **variables.tf**: Contains configurable variables.

## Variables

| Name                  | Description                          | Default |
|-----------------------|--------------------------------------|---------|
| `directus_version`    | Version of Directus to deploy       | `latest`|
| `project_id`          | mittwald project ID                 | -       |
| `redis_max_memory_mb` | Maximum memory for Redis in MB      | `128`   |
| `admin_email`         | Admin email for Directus            | -       |
| `admin_password`      | Admin password for Directus         | -       |

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Feel free to submit issues or pull requests to improve this project.
