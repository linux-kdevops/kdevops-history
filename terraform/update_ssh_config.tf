module "ssh_config_update_host_entries" {
  source  = "linux-kdevops/add-host-ssh-config/kdevops"
  version = "3.0.0"

  ssh_config               = var.ssh_config
  update_ssh_config_enable = var.ssh_config_update
  cmd                      = "update"
  shorthosts               = join(",", slice(local.shorthosts, 0, local.kdevops_num_boxes))
  hostnames                = join(",", slice(local.ipv4s, 0, local.kdevops_num_boxes))
  ports                    = "22"
  user                     = var.ssh_config_user == "" ? "" : var.ssh_config_user
  id                       = replace(var.ssh_config_pubkey_file, ".pub", "")
  strict                   = var.ssh_config_use_strict_settings != "true" ? "" : "true"
  use_backup               = var.ssh_config_backup != "true" || var.ssh_config == "/dev/null" ? "" : "true"
  backup_postfix           = "kdevops"
  kexalgorithms            = var.ssh_config_kexalgorithms == "" ? "" : var.ssh_config_kexalgorithms
}
