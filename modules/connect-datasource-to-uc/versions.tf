terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    guardium-data-protection = {
      source = "na.artifactory.swg-devops.com/ibm/guardium-data-protection"
      version = "0.0.4"
    }
  }
}
