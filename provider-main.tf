###########################
## Azure Provider - Main ##
###########################

# Define Terraform provider
terraform {
  # required_version = "~> 1.15"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}

  environment = "public"

  # Only use explicit credentials when provided (service principal / automation).
  # Leave empty to authenticate via Azure CLI (`az login`), Managed Identity, or environment.
  subscription_id = var.azure-subscription-id != "" ? var.azure-subscription-id : null
  client_id       = var.azure-client-id != "" ? var.azure-client-id : null
  client_secret   = var.azure-client-secret != "" ? var.azure-client-secret : null
  tenant_id       = var.azure-tenant-id != "" ? var.azure-tenant-id : null
}
