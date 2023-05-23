locals {
  shorthosts	= oci_core_instance.kdevops_instance.*.display_name
  ipv4s		= oci_core_instance.kdevops_instance.*.private_ip
}
