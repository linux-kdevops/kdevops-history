locals {
  limit_count = var.ssh_config_update != "true" || var.openstack_cloud == "minicloud" ? 0 : local.num_boxes
  shorthosts = openstack_compute_instance_v2.kdevops_instances.*.name
  ipv4s = openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4
}

resource "null_resource" "ansible_call" {
  provisioner "local-exec" {
    command = var.openstack_cloud == "minicloud" ? "echo yielding to minicloud ansible call" : local.ansible_cmd
  }
  depends_on = [ module.ssh_config_update_host_entries ]
}
