variable "directus_version" {
  type = string
  default = "11"
  description = "Directus version to install; this needs to be a valid tag from https://hub.docker.com/r/directus/directus/tags"
}

variable "description" {
  description = "Description for the Directus container."
  type        = string
  default     = "Directus Headless CMS"
}

variable "admin_email" {
  description = "Directus admin email."
  type        = string
}

variable "admin_password" {
  description = "Directus admin password."
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "The mittwald project ID to deploy resources into."
  type        = string
}

variable "redis_max_memory_mb" {
  description = "Maximum memory for the Redis cache in MB."
  type        = number
  default     = 128
}