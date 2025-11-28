# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# This module connects a data source to Guardium Universal Connector
# Supports both multipart upload (recommended) and legacy SFTP methods

locals {
  udc_name = var.udc_name
  udc_csv  = var.udc_csv_parsed
}

# Create a temporary local CSV file with the profile configuration
# Using path.root to ensure CSV is written to customer's workspace, not cached module directory
resource "local_file" "csv_temp" {
  content  = local.udc_csv
  filename = "${path.root}/.terraform/${var.udc_name}.csv"
}

# LEGACY METHOD: Upload CSV via SFTP (only used when use_multipart_upload = false)
resource "terraform_data" "copy_csv" {
  count      = var.use_multipart_upload ? 0 : 1
  depends_on = [local_file.csv_temp]
  
  input = {
    local_file_path          = local_file.csv_temp.filename
    remote_file_path         = format("%s/%s.csv", var.profile_upload_directory, var.udc_name)
    profile_upload_directory = var.profile_upload_directory
    profile_api_directory    = var.profile_api_directory
    gdp_server               = var.gdp_server
    gdp_ssh_username         = var.gdp_ssh_username
    gdp_ssh_privatekeypath   = var.gdp_ssh_privatekeypath
  }

  provisioner "local-exec" {
    command = <<-EOT
      sftp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${self.input.gdp_ssh_privatekeypath} ${self.input.gdp_ssh_username}@${self.input.gdp_server} <<EOF
put ${self.input.local_file_path} ${self.input.remote_file_path}
bye
EOF
    EOT
  }
}

# Authenticate with Guardium to get OAuth access token
data "guardium-data-protection_authentication" "access_token" {
  client_secret = var.client_secret
  username      = var.gdp_username
  password      = var.gdp_password
  client_id     = var.client_id
}

# Import Universal Connector profiles from CSV file
# NEW METHOD: When use_multipart_upload=true, uploads file via multipart/form-data
# LEGACY METHOD: When use_multipart_upload=false, reads from server path after SFTP upload
resource "guardium-data-protection_import_profiles" "import_profiles" {
  depends_on = [
    local_file.csv_temp,
    terraform_data.copy_csv
  ]
  access_token = data.guardium-data-protection_authentication.access_token.access_token
  path_to_file = var.use_multipart_upload ? abspath(local_file.csv_temp.filename) : format("%s/%s.csv", var.profile_api_directory, var.udc_name)
  update_mode  = true
}

# Install the Universal Connector on the specified Guardium Managed Unit
resource "guardium-data-protection_install_connector" "install_connector" {
  depends_on   = [guardium-data-protection_import_profiles.import_profiles]
  access_token = data.guardium-data-protection_authentication.access_token.access_token
  udc_name     = local.udc_name
  gdp_mu_host  = var.gdp_mu_host
}

# Output the generated CSV content for debugging
output "profile_csv" {
  value       = local.udc_csv
  description = "The generated Universal Connector profile CSV content"
}

# Output the access token for testing
output "access_token" {
  value       = data.guardium-data-protection_authentication.access_token.access_token
  description = "OAuth access token for Guardium API"
  sensitive   = true
}