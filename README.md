#This Terraform script is designed to create a virtual machine running Windows Server 2019 on the Microsoft Azure cloud platform. To ensure secure access and authorization with my Azure account, I have utilized a separate Terraform configuration file named "provider.tf" to configure the necessary provider settings.

To use this script successfully, you need to update specific fields in the code to align with the details of your Microsoft Azure account. By doing so, you can effectively deploy a Windows Server 2019 virtual machine with the desired configurations tailored to your requirements:

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
  tenant_id = "XXXXXXXXXXXXX"
  client_id = "XXXXXXXXXXX"
  client_secret = "XXXXXXXXXXXXXX"
  features {}
}

You can modify the username and password for the virtual machine on line numbers 123 and 124. Simply make the necessary changes to these lines to set the desired username and password for the VM.
