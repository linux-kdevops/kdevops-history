# You may want to enable this if for example your azure subscription is
# the demo one. As of May 2019 you get only 4 cores, so if you are
# creating more than 4 nodes it'd fail. Setting this to true will
# use limit_num_boxes to ensure we don't provision more than this
# number of boxes, in case your vagrant_boxes list has more than this
# limit.
#
# We set this to true for now to ensure a good experience from users
# of this fs tests azure provider, assuming they're also using the
# azure demo account. Set this to "no" on your terraform.tfvars file
# to override.
variable "limit_boxes" {
  description = "Limit the number of nodes created"
  default     = "yes"
}

# Seems to be the default for number of cores allowed on the azure demo account.
variable "limit_num_boxes" {
  description = "The max number of boxes we're allowing terraform to create for us"
  default     = "4"
}

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

variable "ssh_username" {
  description = "The ssh user to use"
  default     = "aurelia"
}

variable "ssh_pubkey_file" {
  description = "Path to the ssh public key file, alternative to ssh_pubkey_data"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_pubkey_data" {
  description = "The ssh public key data"

  # for instance it coudl be "ssh-rsa AAetcccc"
  default = ""
}

