# Global makefile variables
UNAME_PREFIX=$(shell uname -s | tr '[:upper:]' '[:lower:]')
YAML_PLUGIN_URL_DOWNLOAD=https://github.com/ashald/terraform-provider-yaml/releases/download
YAML_PLUGIN_NAME=terraform-provider-yaml
YAML_PLUGIN_VERSION=v2.0.2
YAML_PLUGIN_ARCH=amd64
YAML_PLUGIN_FILE=$(YAML_PLUGIN_NAME)_$(YAML_PLUGIN_VERSION)-$(UNAME_PREFIX)-$(YAML_PLUGIN_ARCH)
YAML_PLUGIN_URL="$(YAML_PLUGIN_URL_DOWNLOAD)/$(YAML_PLUGIN_VERSION)/$(YAML_PLUGIN_FILE)"
