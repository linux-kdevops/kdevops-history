locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.kdevops_num_boxes
  shorthosts  = google_compute_instance.kdevops_instances.*.name
  all_ipv4s   = local.ipv4s
}
