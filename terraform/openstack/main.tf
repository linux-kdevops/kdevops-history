# Openstack terraform provider main

resource "openstack_networking_network_v2" "kdevops_private_net" {
	count		= var.private_net_enabled ? 1 : 0
	name		= "kdevops_private_net"
	admin_state_up	= "true"
}

resource "openstack_networking_subnet_v2" "kdevops_private_subnet" {
	count		= var.private_net_enabled ? 1 : 0
	name 		= "kdevops_private_subnet"
	network_id	= "${openstack_networking_network_v2.kdevops_private_net[0].id}"
	cidr		= format("%s/%d", var.private_net_prefix, var.private_net_mask)
}

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
  count           = local.kdevops_num_boxes
  name            = element(var.kdevops_nodes, count.index)
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.ssh_pubkey_name
  security_groups = [openstack_compute_secgroup_v2.kdevops_security_group.name]
  network {
    name          = var.public_network_name
  }
}

resource "openstack_compute_interface_attach_v2" "kdevops_net_attach" {
  count           = var.private_net_enabled ? local.kdevops_num_boxes : 0
  instance_id     = "${openstack_compute_instance_v2.kdevops_instances[count.index].id}"
  network_id      = "${openstack_networking_network_v2.kdevops_private_net[0].id}"
  # needed to work around race in openstack provider
  depends_on	  = [openstack_networking_subnet_v2.kdevops_private_subnet]
}

resource "openstack_blockstorage_volume_v3" "kdevops_data_disk" {
  count                = local.kdevops_num_boxes
  name                 = format("kdevops-data-disk-%02d", count.index + 1)
  size                 = 80
}

resource "openstack_blockstorage_volume_v3" "kdevops_scratch_disk" {
  count                = local.kdevops_num_boxes
  name                 = format("kdevops-scratch-disk-%02d", count.index + 1)
  size                 = 80
}

resource "openstack_compute_volume_attach_v2" "kdevops_data_disk_attach" {
  count                = local.kdevops_num_boxes
  volume_id            = openstack_blockstorage_volume_v3.kdevops_data_disk[count.index].id
  instance_id          = element(openstack_compute_instance_v2.kdevops_instances.*.id, count.index)
}

resource "openstack_compute_volume_attach_v2" "kdevops_scratch_disk_attach" {
  count                = local.kdevops_num_boxes
  volume_id            = openstack_blockstorage_volume_v3.kdevops_scratch_disk[count.index].id
  instance_id          = element(openstack_compute_instance_v2.kdevops_instances.*.id, count.index)
}
