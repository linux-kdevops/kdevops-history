# This is a relatively new feature, reading cloud.yaml and friends. Even
# though older openstack solutions don't support this, we keep things simple
# and ask you to use these files for now.
#
# If its a public cloud we may add support for extra processing / output
# for each one on its respective cloudname.tf file.
variable "openstack_cloud" {
    description = "Name of your cloud on clouds.yaml"
    default  = "minicloud"
}

variable "ssh_pubkey_file" {
  description = "Path to the ssh public key file, alternative to ssh_pubkey_data"
  # For example:
  # default  = "~/.ssh/minicloud.pub"
  default  = ""
}

variable "ssh_pubkey_name" {
  description = "Name of already existing pubkey or the new one you are about to upload, this must be set"
  default  = "fstests-pubkey"
}

variable "ssh_pubkey_data" {
  description = "The ssh public key data"
  # for instance it coudl be "ssh-rsa AAetcccc"
  default  = ""
}

variable "limit_boxes" {
    description = "Limit the number of nodes created"
    default  = "yes"
}

# minicloud lets us use 5 max
variable "limit_num_boxes" {
    description = "The max number of boxes we're allowing terraform to create for us"
    default  = "5"
}

variable "image_name" {
    description = "Type of image"
    default = "Debian 10 ppc64le"
}

# Note: at least if using minicloud you're allowed 5 instances but only
# 8 cores and 10 GiB of RAM. If you use minicloud.max you max out all
# core limits right away. By default we use here the minicloud.tiny
# to let at you at least create a few instances.
variable "flavor_name" {
    description = "Flavor of image"
    default = "minicloud.tiny"
}

variable "instance_prefix" {
    description = "The prefix of the VM instance name"
    default  = "my-fun"
}
