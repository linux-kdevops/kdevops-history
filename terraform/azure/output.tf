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

output "fstest_hosts" {
  value = data.null_data_source.host_names.*.outputs.value
}

data "azurerm_public_ip" "public_ips" {
  count = local.num_boxes

  # Note: the name must match the respective name used for the public ip
  # for the node.
  name                = format("fstests_pub_ip_%02d", count.index + 1)
  resource_group_name = azurerm_resource_group.fstests_group.name
}

output "fstest_public_ip_addresses" {
  value = data.azurerm_public_ip.public_ips.*.ip_address
}

