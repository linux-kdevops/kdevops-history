locals {
  shorthosts  = google_compute_instance.kdevops_instances.*.name
  all_ipv4s   = local.ipv4s
}
