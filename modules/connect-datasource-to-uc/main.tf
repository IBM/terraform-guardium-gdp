locals {
  udc_name =  var.udc_name
  udc_csv = var.udc_csv_parsed
}

resource "terraform_data" "copy_csv" {
  input = {
    path_to_file     = format("/tmp/%s.csv", var.udc_name)
    content          = local.udc_csv
    gdp_server       = var.gdp_server
    gdp_ssh_username = var.gdp_ssh_username
    gdp_private_key  = file(var.gdp_ssh_privatekeypath)
  }

  connection {
    host        = self.input.gdp_server
    type        = "ssh"
    user        = self.input.gdp_ssh_username
    private_key = self.input.gdp_private_key
    agent       = "false"
  }

  provisioner "file" {
    content     = self.input.content
    destination = self.input.path_to_file
  }

  provisioner "remote-exec" {
    when   = destroy
    inline = ["rm -rf ${self.input.path_to_file}"]
  }
}

data "guardium-data-protection_authentication" "access_token" {
  client_secret = var.client_secret
  username = var.gdp_username
  password = var.gdp_password
  client_id = var.client_id
}

output "test" {
  value = data.guardium-data-protection_authentication.access_token.access_token
}

resource "guardium-data-protection_import_profiles" "import_profiles" {
  access_token = data.guardium-data-protection_authentication.access_token.access_token
  path_to_file = terraform_data.copy_csv.output.path_to_file
  update_mode = true
}

resource "guardium-data-protection_install_connector" "install_connector" {
  depends_on = [guardium-data-protection_import_profiles.import_profiles]
  access_token = data.guardium-data-protection_authentication.access_token.access_token
  udc_name     = local.udc_name
  gdp_mu_host  = var.gdp_mu_host
}

output "profile_csv" {
  value = local.udc_csv
}