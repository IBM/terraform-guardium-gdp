terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    guardium-data-protection = {
      # Repo name: terraform-provider-guardium-data-protection
      source  = "IBM/guardium-data-protection"
      # Tag: v1.4.9
      version = "= 1.4.9"
    }
  }
}
