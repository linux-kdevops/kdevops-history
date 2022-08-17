resource "oci_core_instance" "kdevops_instance" {
  count = local.num_boxes

  availability_domain = var.oci_availablity_domain
  compartment_id = var.oci_compartment_ocid
  shape = var.oci_shape

  source_details {
    source_id = var.oci_os_image_ocid
    source_type = "image"
  }

  display_name = element(var.kdevops_nodes, count.index)

  create_vnic_details {
    assign_public_ip = false
    subnet_id = var.oci_subnet_ocid
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_config_pubkey_file)
  }

  preserve_boot_volume = false
}

resource "oci_core_volume" "kdevops_data_disk" {
  count = local.num_boxes

  compartment_id = var.oci_compartment_ocid

  availability_domain = var.oci_availablity_domain
  display_name = var.oci_data_volume_display_name
  size_in_gbs = 50
}

resource "oci_core_volume" "kdevops_sparse_disk" {
  count = local.num_boxes

  compartment_id = var.oci_compartment_ocid

  availability_domain = var.oci_availablity_domain
  display_name = var.oci_sparse_volume_display_name
  size_in_gbs = 250
}

resource "oci_core_volume_attachment" "kdevops_data_volume_attachment" {
  count = local.num_boxes

  attachment_type = "paravirtualized"
  instance_id = element(oci_core_instance.kdevops_instance.*.id, count.index)
  volume_id = element(oci_core_volume.kdevops_data_disk.*.id, count.index)

  device = var.oci_data_volume_device_file_name
}

resource "oci_core_volume_attachment" "kdevops_sparse_disk_attachment" {
  count = local.num_boxes

  attachment_type = "paravirtualized"
  instance_id = element(oci_core_instance.kdevops_instance.*.id, count.index)
  volume_id = element(oci_core_volume.kdevops_sparse_disk.*.id, count.index)

  device = var.oci_sparse_volume_device_file_name
}
