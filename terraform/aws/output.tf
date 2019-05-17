# All generic output goes here

locals {
  ssh_key_i = "${format(" %s%s ", var.ssh_pubkey_file != "" ? "-i " : "", var.ssh_pubkey_file != "" ? replace(var.ssh_pubkey_file, ".pub", "") : "")}"
}

data "null_data_source" "group_hostnames_and_ips" {
  count  = "${local.num_boxes}"
  inputs = {
    value = "${format("%30s  :  ssh %s@%s %s ", replace(urlencode(element(split("name: ", element(data.yaml_list_of_strings.list.output, count.index)), 1)), "%7D", ""), var.ssh_username, element(aws_eip.fstests_eip.*.public_ip, count.index), local.ssh_key_i)}"
  }
}

output "login_using" {
  value = "${data.null_data_source.group_hostnames_and_ips.*.outputs}"
}
