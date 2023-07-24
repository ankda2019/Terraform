terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.66.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "XXXXXXXXXXXXX"
  tenant_id = "XXXXXXXXXXXXXXXXX"
  client_id = "XXXXXXXXXXXXXXXXX"
  client_secret = "XXXXXXXXXXXXXXXXX"
  features {}
}
