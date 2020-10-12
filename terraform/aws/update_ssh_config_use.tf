locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  all_tags = aws_instance.kdevops_instance.*.tags
  shorthosts = [
    for tags in local.all_tags:
      format("%s", lookup(tags, "Name"))
  ]
  all_ipv4s = aws_eip.kdevops_eip.*.public_ip
  ipv4s = [
    for ip in local.all_ipv4s:
      ip == "" ? "0.0.0.0" : ip
  ]
}
