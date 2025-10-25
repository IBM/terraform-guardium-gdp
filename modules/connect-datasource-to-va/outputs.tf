# Connect Datasource to GDP Module - Outputs

output "datasource_payload" {
  description = "The complete datasource configuration payload"
  value       = var.datasource_payload
}

output "guardium_server" {
  description = "Hostname of the Guardium Data Protection server"
  value       = var.gdp_server
}

output "access_token" {
  description = "Access token for Guardium API (sensitive)"
  value       = data.guardium-data-protection_authentication.access_token.access_token
  sensitive   = true
}