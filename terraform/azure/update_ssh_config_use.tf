locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  shorthosts  = azurerm_linux_virtual_machine.kdevops_vm.*.name
  ipv4s       = data.azurerm_public_ip.public_ips.*.ip_address
}
