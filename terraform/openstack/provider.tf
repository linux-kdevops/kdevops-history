terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>1.47.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>2.1"
    }
  }
}

provider "openstack" {
  # We prefer this method as it means you also get to use standard openstack
  # utilities that also use and share the same configuration files.
  # First clouds-public.yaml is read, then clouds.yaml and last secure.yaml.
  #
  # For more details or examples see:
  # https://docs.openstack.org/os-client-config/latest/user/configuration.html
  # https://www.inovex.de/blog/managing-secrets-openstack-terraform/
  cloud = var.openstack_cloud
}
