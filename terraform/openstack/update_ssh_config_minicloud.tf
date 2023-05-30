locals {
  shorthosts_minicloud  = openstack_compute_instance_v2.kdevops_instances.*.name
  ports_minicloud = [
    for ip in openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4 :
    format("%s%03d", element(split(".", ip), 2, ), ceil(element(split(".", ip), 3, )))
  ]
}

module "ssh_config_update_host_entries_minicloud" {
  source  = "linux-kdevops/add-host-ssh-config/kdevops"
  version = "3.0.0"

  ssh_config               = var.ssh_config
  update_ssh_config_enable = (var.openstack_cloud == "minicloud" && local.kdevops_num_boxes > 0) ? "true" : ""
  cmd                      = "update"
  shorthosts               = join(",", slice(local.shorthosts_minicloud, 0, local.kdevops_num_boxes))
  hostnames                = "minicloud.parqtec.unicamp.br"
  ports                    = join(",", slice(local.ports_minicloud, 0, local.kdevops_num_boxes))
  user                     = var.ssh_config_user == "" ? "" : var.ssh_config_user
  id                       = replace(var.ssh_config_pubkey_file, ".pub", "")
  strict                   = var.ssh_config_use_strict_settings != "true" ? "" : "true"
  use_backup               = var.ssh_config_backup != "true" || var.ssh_config == "/dev/null" ? "" : "true"
  backup_postfix           = "kdevops"
  kexalgorithms            = var.ssh_config_kexalgorithms == "" ? "" : var.ssh_config_kexalgorithms
}
