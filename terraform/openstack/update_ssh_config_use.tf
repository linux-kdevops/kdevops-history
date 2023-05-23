locals {
  shorthosts  = openstack_compute_instance_v2.kdevops_instances.*.name
  ipv4s       = openstack_compute_instance_v2.kdevops_instances.*.access_ip_v4
}
