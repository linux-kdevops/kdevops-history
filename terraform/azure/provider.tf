# Describes the provider we are going to use. This will automatically
# phone home to HashiCorp to download the latest azure plugins being
# described here.

provider "azurerm" {
  # any non-beta version >= 1.27.0 and < 1.26.0, e.g. 1.27.1
  version = "~>1.27.0"

  subscription_id             = var.subscription_id
  client_id                   = var.application_id
  client_certificate_path     = var.client_certificate_path
  client_certificate_password = var.client_certificate_password
  tenant_id                   = var.tenant_id
}

