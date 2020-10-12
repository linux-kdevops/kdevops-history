variable "limit_boxes" {
  description = "Limit the number of nodes created"
  default     = "yes"
}

# Seems to be the default for number of cores allowed on the azure demo account.
variable "limit_num_boxes" {
  description = "The max number of boxes we're allowing terraform to create for us"
  default     = "2"
}

variable "project" {
  description = "Your project name"
  default     = "some-rando-project"
}

variable "credentials" {
  description = "Path to the your service account json credentials file"
  default     = "account.json"
}

# https://cloud.google.com/compute/docs/regions-zones/
# This is LA, California
variable "region" {
  description = "Region location"
  default     = "us-west2-c"
}

# https://cloud.google.com/compute/docs/machine-types
variable "machine_type" {
  description = "Machine type"
  default     = "n1-standard-1"
}

variable "image_name" {
  description = "Name of image to use"
  default     = "debian-cloud/debian-10"
}

variable "scratch_disk_interface" {
  description = "The type of interface for the scratch disk, SCSI, or NVME"
  default     = "NVME"
}
