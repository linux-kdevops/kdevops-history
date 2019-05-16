.PHONY: deps all

TOPDIR=$(CURDIR)/../../
include $(TOPDIR)/globals.mk

all: deps

deps: $(YAML_PLUGIN_FILE)

$(YAML_PLUGIN_FILE):
	@echo "SYMLINK $(YAML_PLUGIN_FILE) for Azure ..."
	@ln -s ../$(YAML_PLUGIN_FILE) .

clean:
	@rm -f $(YAML_PLUGIN_FILE)
