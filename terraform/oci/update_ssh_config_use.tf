locals {
  limit_count	= var.ssh_config_update != "True" ? 0 : local.num_boxes
  shorthosts	= oci_core_instance.kdevops_instance.*.display_name
  ipv4s		= oci_core_instance.kdevops_instance.*.private_ip
}
