output "container_id" {
  description = "The ID of the Directus container."
  value       = mittwald_container_stack.directus.containers["directus"].id
}

output "container_url" {
  description = "The URL of the Directus container."
  value       = local.url