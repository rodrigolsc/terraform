terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 2.46.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
  }
}

resource "azurerm_resource_group" "rodrigo" {
  name     = "atividade02"
  location = "East US"
}

output "public-ip-vm" {
  value = azurerm_public_ip.rodrigo-ip.ip_address
}


