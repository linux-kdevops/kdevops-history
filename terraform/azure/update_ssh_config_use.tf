locals {
  shorthosts  = azurerm_linux_virtual_machine.kdevops_vm.*.name
  ipv4s       = data.azurerm_public_ip.public_ips.*.ip_address
}
