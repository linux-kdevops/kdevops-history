terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.11.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>2.1"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id             = var.subscription_id
  client_id                   = var.application_id
  client_certificate_path     = var.client_certificate_path
  client_certificate_password = var.client_certificate_password
  tenant_id                   = var.tenant_id
}
