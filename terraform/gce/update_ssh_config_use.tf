locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  shorthosts = google_compute_instance.kdevops_instances.*.name
  all_ipv4s = local.ipv4s
}

resource "null_resource" "ansible_call" {
  provisioner "local-exec" {
    command = local.ansible_cmd
  }
  depends_on = [ module.ssh_config_update_host_entries ]
}
