# Generic import of data. Terraform doesn't support reading YAML files
# directly. Instead we need to use a terraform plugin for that. We do
# this so we can just use *one* file for provisioning which is shared
# for both simple Vagrant solutions and cloud terraform configurations.
#
# To use this just symlink to this in your respective provider directory.
# Terraform will process all *.tf files in alphabetical order, but the
# order does not matter as terraform is declarative.

# This lets you override the node configuraiton file with an environment
# variable, TN_VAR_DEVOPS_NODE_CONFIG.

variable "file_yaml_vagrant_boxes" {
    description = "Path to the yaml file which has the vagrant_boxes declared as list"
    default = "../nodes.yaml"
}

variable "ssh_config" {
    description = "Path to your ssh_config"
    default = "~/.ssh/config"
}

variable "ssh_config_update" {
    description = "Set this to true if you want terraform to update your ssh_config with the provisioned set of hosts"
    default = "true"
}

# Debian AWS ami's use admin as the default user, we override it with cloud-init
# for whatever username you set here.
variable "ssh_config_user" {
    description = "If ssh_config_update is true, and this is set, it will be the user set for each host on your ssh config"
    default = "admin"
}

variable "ssh_config_pubkey_file" {
  description = "Path to the ssh public key file, alternative to ssh_pubkey_data"
  default     = "~/.ssh/kdevops_terraform.pub"
}

variable "ssh_config_use_strict_settings" {
    description = "Whether or not to use strict settings on ssh_config"
    default = "yes"
}

variable "ssh_config_backup" {
    description = "Set this to true if you want to backup your ssh_config per update"
    default = "true"
}

variable "ssh_config_kexalgorithms" {
    description = "If set, this sets a custom ssh kexalgorithms"
    default = ""
}

variable "ansible_provision" {
    description = "Set this to true if you want to enable ansible provisioning"
    default = "true"
}

variable "ansible_inventory" {
    description = "The name of the ansible inventory file"
    default = "hosts"
}

variable "ansible_playbookdir" {
    description = "The name of the ansible playbook directory"
    default = "playbooks"
}

variable "ansible_provision_playbook" {
    description = "The name of the playbook to run for provisioning"
    default = "devconfig.yml"
}

provider "null" {
  # any non-beta version >= 2.0.0 and < 2.1.0, e.g. 2.0.1
  version = "~> 2.1"
}

# We'd have to update our Makefiles to do the right thing, if we
# add this, terraform can't find the stupid plugin.
#provider "yaml" {
# any non-beta version >= 2.0.0 and < 2.1.0, e.g. 2.0.1
#  version = "~>2.0"
#}

locals {
  input = "${var.file_yaml_vagrant_boxes}"
}

# https://github.com/ashald/terraform-provider-yaml
data "yaml_map_of_strings"  "normal" { input = "${file(local.input)}" }
data "yaml_map_of_strings"  "flat"   {
	input = "${file(local.input)}"
	flatten="/"
}

# You *must* have a section your YAML file with "vagrant_boxes" declaring a
# list of hosts.
data "yaml_list_of_strings" "list"   { input = "${data.yaml_map_of_strings.normal.output["vagrant_boxes"]}" }

locals {
  vagrant_num_boxes = "${length(data.yaml_list_of_strings.list.output)}"
}

locals {
  num_boxes = "${var.limit_boxes == "yes" ? min(local.vagrant_num_boxes, var.limit_num_boxes) : local.vagrant_num_boxes }"
}

data "template_file" "ansible_cmd" {
  template = "${file("ansible_provision_cmd.tpl")}"
  vars = {
    inventory = "../../${var.ansible_inventory}"
    playbook_dir = "../../${var.ansible_playbookdir}/"
    provision_playbook = "${var.ansible_provision_playbook}"
    extra_args = "--extra-vars='data_home_dir=/home/${var.ssh_config_user}'"
  }
}

locals {
  skip_ansible_cmd = "echo Skipping ansible provisioning"
  ansible_cmd = var.ansible_provision == "true" ? "${data.template_file.ansible_cmd.rendered}" : "${local.skip_ansible_cmd}"
}
