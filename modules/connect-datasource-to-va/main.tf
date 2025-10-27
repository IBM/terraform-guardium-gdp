# Connect Datasource to GDP Module - Main Configuration

# Step 1: Authenticate with Guardium API and get access token
data "guardium-data-protection_authentication" "access_token" {
  client_secret = var.client_secret
  username      = var.gdp_username
  password      = var.gdp_password
  client_id     = var.client_id
}

resource "guardium-data-protection_register_va_datasource" "register_va_datasource" {
  payload = var.datasource_payload
  access_token = data.guardium-data-protection_authentication.access_token.access_token
}

# resource "guardium-data-protection_configure_va_datasource" "configure_va_datasource" {
#   # Required parameters
#   datasource_name     = var.datasource_name
#   assessment_schedule = var.assessment_schedule
#   assessment_day      = var.assessment_day
#   assessment_time     = var.assessment_time
#   access_token        = data.guardium-data-protection_authentication.access_token.access_token
#   enabled             = true
# }
#
# resource "guardium-data-protection_configure_va_notifications" "configure_notifications" {
#   count = var.enable_notifications && length(var.notification_emails) > 0 ? 1 : 0
#
#   datasource_name      = var.datasource_name
#   notification_type    = "email"
#   notification_emails  = var.notification_emails
#   notification_severity = var.notification_severity
#
#   access_token         = data.guardium-data-protection_authentication.access_token.access_token
#   enabled              = true
# }