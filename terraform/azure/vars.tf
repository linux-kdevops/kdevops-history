variable "client_certificate_path" {
    description = "Path to the service principal PFX file for this application"
    default  = "./service-principal.pfx"
}

variable "client_certificate_password" {
    description = "The password to the service principal PFX file"
    default  = "someHardPassword"
}

variable "application_id" {
    description = "The application ID"
    default  = "anotherGUID"
}

variable "subscription_id" {
    description = "Your subscription ID"
    default  = "anotherGUID"
}

variable "tenant_id" {
    description = "Azure tenant ID"
    default  = "someLONGGUID"
}

variable "ssh_username" {
    description = "The ssh user to use"
    default  = "aurelia"
}

variable "ssh_pubkey_data" {
    description = "The ssh public key data"
    default  = "ssh-rsa AA{snip}asdf"
}
