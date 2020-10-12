data "null_data_source" "host_names" {
  count = local.num_boxes
  inputs = {
    value = replace(
      urlencode(
        element(
          split(
            "name: ",
            element(data.yaml_list_of_strings.list.output, count.index),
          ),
          1,
        ),
      ),
      "%7D",
      "",
    )
  }
}

output "kdevops_hosts" {
  value = data.null_data_source.host_names.*.outputs.value
}

data "azurerm_public_ip" "public_ips" {
  count               = local.num_boxes
  name                = element(azurerm_public_ip.kdevops_publicip.*.name, count.index)
  resource_group_name = azurerm_resource_group.kdevops_group.name
  depends_on          = [ azurerm_linux_virtual_machine.kdevops_vm ]
}

output "kdevops_public_ip_addresses" {
  value = data.azurerm_public_ip.public_ips.*.ip_address
}

locals {
  ssh_key_i = "${format(" %s%s ", var.ssh_config_pubkey_file != "" ? "-i " : "", var.ssh_config_pubkey_file != "" ? replace(var.ssh_config_pubkey_file, ".pub", "") : "")}"
}

data "null_data_source" "group_hostnames_and_ips" {
  count  = "${local.num_boxes}"
  inputs = {
    # In theory using "${self.triggers["name"]}" and "${self.triggersp["ip"]}"
    # would be nice but it is not supported in this context, only in the
    # provisioner and connection contexts.
    value = "${format("%30s  :  ssh %s@%s %s ", element(azurerm_linux_virtual_machine.kdevops_vm.*.name, count.index), var.ssh_config_user, element(azurerm_public_ip.kdevops_publicip.*.ip_address, count.index), local.ssh_key_i)}"
  }
}

output "login_using" {
  value = "${data.null_data_source.group_hostnames_and_ips.*.outputs}"
}
