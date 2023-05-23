variable "client_certificate_path" {
  description = "Path to the service principal PFX file for this application"
  default     = "./service-principal.pfx"
}

variable "client_certificate_password" {
  description = "The password to the service principal PFX file"
  default     = "someHardPassword"
}

variable "application_id" {
  description = "The application ID"
  default     = "anotherGUID"
}

variable "subscription_id" {
  description = "Your subscription ID"
  default     = "anotherGUID"
}

variable "tenant_id" {
  description = "Azure tenant ID"
  default     = "someLONGGUID"
}

variable "ssh_pubkey_data" {
  description = "The ssh public key data"

  # for instance it coudl be "ssh-rsa AAetcccc"
  default = ""
}

variable "resource_location" {
  description = "Resource location"
  default     = "westus"
}

variable "vmsize" {
  description = "VM size"
  default     = "Standard_DS3_v2"
}

variable "managed_disk_type" {
  description = "Managed disk type"
  default     = "Premium_LRS"
}

variable "image_publisher" {
  description = "Storage image publisher"
  default     = "Debian"
}

variable "image_offer" {
  description = "Storage image offer"
  default     = "debian-10"
}

variable "image_sku" {
  description = "Storage image sku"
  default     = "10"
}

variable "image_version" {
  description = "Storage image version"
  default     = "latest"
}
