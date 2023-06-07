locals {
  shorthosts	= oci_core_instance.kdevops_instance.*.display_name
  ipv4s		= (
    var.oci_assign_public_ip == "false" ?
    oci_core_instance.kdevops_instance.*.private_ip :
    oci_core_instance.kdevops_instance.*.public_ip
  )
}
