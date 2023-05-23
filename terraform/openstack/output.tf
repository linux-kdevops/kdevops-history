data "null_data_source" "group_hostnames_and_ips" {
  count = local.kdevops_num_boxes
  inputs = {
    value = format(
      "%30s  :  %s",
      element(var.kdevops_nodes, count.index),
      element(
        openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4,
        count.index,
      ),
    )
  }
}

output "kdevops_hosts_and_ipv4" {
  value = data.null_data_source.group_hostnames_and_ips.*.outputs
}

