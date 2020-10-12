locals {
  limit_count_minicloud = var.ssh_config_update != "true" || var.openstack_cloud != "minicloud" ? 0 : local.num_boxes
  shorthosts_minicloud = openstack_compute_instance_v2.kdevops_instances.*.name
  ports_minicloud = [
    for ip in openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4:
      format("%s%03d", element(split(".", ip),2,), ceil(element(split(".", ip),3,)))
  ]
}

module "ssh_config_update_host_entries_minicloud" {
  source  = "mcgrof/add-host-ssh-config/kdevops"
  version = "2.2.1"

  ssh_config = var.ssh_config
  update_ssh_config_enable = local.limit_count_minicloud > 0 ? "true" : ""
  cmd = "update"
  shorthosts = join(",", slice(local.shorthosts_minicloud, 0, local.limit_count_minicloud))
  hostnames = "minicloud.parqtec.unicamp.br"
  ports = join(",", slice(local.ports_minicloud, 0, local.limit_count_minicloud))
  user = var.ssh_config_user == "" ? "" : var.ssh_config_user
  id = replace(var.ssh_config_pubkey_file, ".pub", "")
  strict = var.ssh_config_use_strict_settings != "true" ? "" : "true"
  use_backup = var.ssh_config_backup != "true" || var.ssh_config == "/dev/null" ? "" : "true"
  backup_postfix = "kdevops"
  kexalgorithms = var.ssh_config_kexalgorithms == "" ? "" : var.ssh_config_kexalgorithms
}

resource "null_resource" "ansible_call" {
  provisioner "local-exec" {
    command = var.openstack_cloud == "minicloud" ? local.ansible_cmd : "echo ignorng minicloud ansible call"
  }
  depends_on = [ module.ssh_config_update_host_entries ]
}
