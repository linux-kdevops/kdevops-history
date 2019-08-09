.PHONY: deps all

TOPDIR=$(CURDIR)/../
include $(CURDIR)/globals.mk

all: deps

DIRS=$(shell find ./* -maxdepth 0 -type d)

$(YAML_PLUGIN_FILE):
	wget -O $(YAML_PLUGIN_FILE) "$(YAML_PLUGIN_URL)"
	chmod +x $(YAML_PLUGIN_FILE)

deps: $(YAML_PLUGIN_FILE)
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i deps; fi; done

clean:
	@rm -f $(YAML_PLUGIN_FILE)
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i clean; fi; done
