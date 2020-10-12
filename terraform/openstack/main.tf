# Openstack terraform provider main

resource "openstack_compute_secgroup_v2" "kdevops_security_group" {
  name        = format("%s-%s", var.instance_prefix, "kdevops_security_group")
  description = "security group for kdevops"

  # SSH
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  # All TCP high ports
  rule {
    from_port   = 1024
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# You can upload your ssh key to the OpenStack interface and just set
# ssh_config_pubkey_file = "" on your terraform.tfvars, this will just use the
# already existing and uploaded key. Even if you already uplaoded the key,
# if you set the ssh_config_pubkey_file variable to the same key, this will just
# upload the same pubkey key again and just use the name in ssh_pubkey_name.
#
# If you haven't yet uploaded your key through the web interface, you can
# set ssh_config_pubkey_file to your pubkey file path, and it will be uplaoded
# and the key name associated with it. Once you 'terraform destroy' only
# the public key resource will be destroyed.
#
# If you want to create a new random key this allows you to do that as well,
# just set ssh_pubkey_data = "" and ssh_config_pubkey_file = "" in your
# terraform.tfvars and a new key pair will be created for you on the fly.
# However note that once this resource is destroyed the private key will
# also be destroyed if you asked terraform to create a new key for you.
resource "openstack_compute_keypair_v2" "kdevops_keypair" {
  name       = var.ssh_pubkey_name
  public_key = var.ssh_pubkey_data != "" ? var.ssh_pubkey_data : var.ssh_config_pubkey_file != "" ? file(var.ssh_config_pubkey_file) : ""
}

resource "openstack_compute_instance_v2" "kdevops_instances" {
  count = local.num_boxes
  name = replace(
    urlencode(
      element(
        split(
          "name: ",
          element(data.yaml_list_of_strings.list.output, count.index),
        ),
        1,
      ),
    ),
    "%7D",
    "",
  )
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.ssh_pubkey_name
  security_groups = [openstack_compute_secgroup_v2.kdevops_security_group.name]
}

