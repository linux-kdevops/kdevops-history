# SPDX-License-Identifier: GPL-2.0
#
PROJECT = kdevops
VERSION = 3
PATCHLEVEL = 0
SUBLEVEL = 1
EXTRAVERSION = -rc1

KDEVOPS_PLAYBOOKS_DIR :=	playbooks
KDEVOPS_HOSTFILE :=		hosts
export KDEVOPS_NODES :=			vagrant/kdevops_nodes.yaml
export KDEVOPS_NODES_TEMPLATE :=	vagrant/kdevops_nodes.yaml.in

all: deps

MAKEFLAGS += --no-print-directory
SHELL := /bin/bash

ifeq ($(V),1)
Q=
NQ=true
else
Q=@
NQ=echo
endif

include scripts/kconfig.Makefile
INCLUDES = -I include/
CFLAGS += $(INCLUDES)

ifeq (,$(wildcard $(CURDIR)/.config))
else
obj-$(CONFIG_INSTALL_ANSIBLE_KDEVOPS)		:= kdevops_install
obj-$(CONFIG_INSTALL_ANSIBLE_KDEVOPS_ROLES)	+= kdevops_ansible_deps
obj-$(CONFIG_TERRAFORM)				+= kdevops_terraform_deps
obj-$(CONFIG_VAGRANT)				+= kdevops_vagrant_install_vagrant
obj-$(CONFIG_VAGRANT_LIBVIRT_INSTALL)		+= kdevops_vagrant_install_libvirt
obj-$(CONFIG_VAGRANT_LIBVIRT_CONFIGURE)		+= kdevops_vagrant_configure_libvirt
obj-$(CONFIG_VAGRANT)				+= kdevops_vagrant_get_Vagrantfile
obj-$(CONFIG_VAGRANT_INSTALL_PRIVATE_BOXES)	+= kdevops_vagrant_boxes
obj-$(CONFIG_VAGRANT_LIBVIRT_VERIFY)		+= kdevops_verify_vagrant_user
endif

ifeq (y,$(CONFIG_FORCE_INSTALL_ANSIBLE_KDEVOPS))
KDEVOPS_FORCE_ANSIBLE_ROLES := --force
else
KDEVOPS_FORCE_ANSIBLE_ROLES :=
endif

BOOTLINUX_ARGS	:=
ifeq (y,$(CONFIG_BOOTLINUX))
TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_VERSION:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_VERSION))
TREE_CONFIG:=config-$(TREE_VERSION)
BOOTLINUX_ARGS	+= target_linux_git=$(TREE_URL)
BOOTLINUX_ARGS	+= target_linux_tree=$(TREE_NAME)
BOOTLINUX_ARGS	+= target_linux_tag=$(TREE_VERSION)
BOOTLINUX_ARGS	+= target_linux_config=$(TREE_CONFIG)
else
endif

export TOPDIR=./

-include Makefile.kdevops

# disable built-in rules for this file
.SUFFIXES:

.config:
	@(								\
	echo "/--------------"						;\
	echo "| $(PROJECT) isn't configured, please configure it" 	;\
	echo "| using one of the following options:"			;\
	echo "| To configure manually:"					;\
	echo "|     make oldconfig"					;\
	echo "|     make menuconfig"					;\
	echo "|"							;\
	echo "| To use defaults you can use:" 				;\
	(cd defconfigs ; for f in $$(ls) ; do				\
		echo "|     make defconfig-$$f"				;\
	done )								;\
	echo "\--"							;\
	false)

$(KDEVOPS_NODES): $(KDEVOPS_NODES_TEMPLATE) .config
	@$(TOPDIR)/scripts/gen_nodes_file.sh

PHONY += clean
clean:
	$(MAKE) -f scripts/build.Makefile $@

PHONY += mrproper
mrproper:
	$(MAKE) -f scripts/build.Makefile clean
	$(MAKE) -f scripts/build.Makefile $@
	@rm -f $(KDEVOPS_NODES)
	@rm -f .config .config.old
	@rm -rf include
	@find terraform/ -type f| egrep -v "terraform/$|terraform/nodes.yaml|terraform/.gitignore" | xargs rm -f

PHONY += help
help:
	$(MAKE) -f scripts/build.Makefile $@

PHONY := deps
deps: $(KDEVOPS_NODES) $(obj-y)

PHONY += kdevops_install
kdevops_install: $(KDEVOPS_NODES)
	@ansible-galaxy install $(KDEVOPS_FORCE_ANSIBLE_ROLES) -r requirements.yml
	@ansible-playbook -i $(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_install.yml

PHONY += linux
linux: $(KDEVOPS_NODES)
	@ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)"
.PHONY: $(PHONY)
