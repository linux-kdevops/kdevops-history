# Describes the provider we are going to use. This will automatically
# phone home to HashiCorp to download the latest azure plugins being
# described here.

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.24.0"

  subscription_id             = "${var.subscription_id}"
  client_id                   = "${var.application_id}"
  client_certificate_path     = "${var.client_certificate_path}"
  client_certificate_password = "${var.client_certificate_password}"
  tenant_id                   = "${var.tenant_id}"
}
