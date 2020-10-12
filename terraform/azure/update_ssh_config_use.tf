locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  shorthosts = azurerm_linux_virtual_machine.kdevops_vm.*.name
  ipv4s = data.azurerm_public_ip.public_ips.*.ip_address
}

resource "null_resource" "ansible_call" {
  provisioner "local-exec" {
    command = local.ansible_cmd
  }
  depends_on = [ module.ssh_config_update_host_entries ]
}
