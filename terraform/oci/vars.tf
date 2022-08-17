variable "limit_boxes" {
  description = "Limit the number of nodes created"
  default     = "no"
}

variable "limit_num_boxes" {
  description = "The max number of boxes we're allowing terraform to create for us"
  default     = "2"
}

variable "oci_region" {
  description = "An OCI region"
  default = ""
}

variable "oci_tenancy_ocid" {
  description = "OCID of your tenancy"
  default = ""
}

variable "oci_user_ocid" {
  description = "OCID of the user calling the API"
  default = ""
}

variable "oci_user_private_key_path" {
  description = "The path of the private key stored on your computer"
  default = ""
}

variable "oci_user_fingerprint" {
  description = "Fingerprint for the key pair being used"
  default = ""
}

variable "oci_availablity_domain" {
  description = "Name of availability domain"
  default = ""
}

variable "oci_compartment_ocid" {
  description = "OCID of compartment"
  default = ""
}

variable "oci_shape" {
  description = "Shape name"
  default = ""
}

variable "oci_os_image_ocid" {
  description = "OCID of OS image"
  default = ""
}

variable "oci_instance_display_name" {
  description = "Name of the instance"
  default = ""
}

variable "oci_subnet_ocid" {
  description = "Subnet OCID"
  default = ""
}

variable "oci_data_volume_display_name" {
  description = "Display name to use for the data volume"
  default = "data"
}

variable oci_data_volume_device_file_name {
  description = "Data volume's device file name"
  default = "/dev/oracleoci/oraclevdb"
}

variable "oci_sparse_volume_display_name" {
  description = "Display name to use for the sparse volume"
  default = "sparse"
}

variable oci_sparse_volume_device_file_name {
  description = "Sparse volume's device file name"
  default = "/dev/oracleoci/oraclevdc"
}
