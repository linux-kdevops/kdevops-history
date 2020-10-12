# Phones home to Hashicorp to get the required Hashicorp plugins.

provider "openstack" {
  # any non-beta version >= 1.19.0 and < 1.20.0, e.g. 1.19.1
  version = "~>1.29.0"

  # We prefer this method as it means you also get to use standard openstack
  # utilities that also use and share the same configuration files.
  # First clouds-public.yaml is read, then clouds.yaml and last secure.yaml.
  #
  # For more details or examples see:
  # https://docs.openstack.org/os-client-config/latest/user/configuration.html:W
  # https://www.inovex.de/blog/managing-secrets-openstack-terraform/
  cloud = var.openstack_cloud
}

