# minicloud specific output

locals {
  ssh_key_i = format(
    " %s%s ",
    var.ssh_config_pubkey_file != "" ? "-i " : "",
    var.ssh_config_pubkey_file != "" ? replace(var.ssh_config_pubkey_file, ".pub", "") : "",
  )
}

# If using minicloud the public IPs are actually mapped to ports. This does
# the tranlation for you.
# https://github.com/Unicamp-OpenPower/minicloud/wiki/Getting-Started-with-Minicloud
data "null_data_source" "group_hostnames_and_ports_v2" {
  count = var.openstack_cloud != "minicloud" ? 0 : local.num_boxes
  inputs = {
    value = format(
      "%30s  :  %s%s%03d%s ",
      replace(
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
      ),
      "ssh debian@minicloud.parqtec.unicamp.br -p ",
      element(
        split(
          ".",
          element(
            openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4,
            count.index,
          ),
        ),
        2,
      ),
      ceil(
        element(
          split(
            ".",
            element(
              openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4,
              count.index,
            ),
          ),
          3,
        ),
      ),
      local.ssh_key_i,
    )
  }
}

output "kdevops_minicloud_port_ip_access_v2" {
  value = data.null_data_source.group_hostnames_and_ports_v2.*.outputs
}

