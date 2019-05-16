data "null_data_source" "group_hostnames_and_ips" {
  count  = "${local.num_boxes}"
  inputs = {
    value = "${format("%30s  :  %s", replace(urlencode(element(split("name: ", element(data.yaml_list_of_strings.list.output, count.index)), 1)), "%7D", ""), element(openstack_compute_instance_v2.fstests_instances.*.access_ip_v4, count.index))}"
  }
}

output "fstest_hosts_and_ipv4" {
  value = "${data.null_data_source.group_hostnames_and_ips.*.outputs}"
}
