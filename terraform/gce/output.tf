locals {
  ssh_key_i = "${format(" %s%s ", var.ssh_config_pubkey_file != "" ? "-i " : "", var.ssh_config_pubkey_file != "" ? replace(var.ssh_config_pubkey_file, ".pub", "") : "")}"
  network_interfaces = google_compute_instance.kdevops_instances.*.network_interface
  access_configs = [
    for net_interface in local.network_interfaces:
      net_interface[0].access_config
  ]
  ipv4s = [
    for access_config in local.access_configs:
      access_config[0].nat_ip
  ]
}

data "null_data_source" "group_hostnames_and_ips" {
  count  = "${local.num_boxes}"
  inputs = {
    # In theory using "${self.triggers["name"]}" and "${self.triggersp["ip"]}"
    # would be nice but it is not supported in this context, only in the
    # provisioner and connection contexts.
    value = "${format("%30s  :  ssh %s@%s %s ", element(google_compute_instance.kdevops_instances.*.name, count.index), var.ssh_config_user, element(local.ipv4s, count.index), local.ssh_key_i)}"
  }
}

output "login_using" {
  value = "${data.null_data_source.group_hostnames_and_ips.*.outputs}"
}
