# SPDX-License-Identifier: GPL-2.0
#
PROJECT = kdevops
VERSION = 3
PATCHLEVEL = 0
SUBLEVEL = 6
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

# kdevops-stage-1-y will be called first.
# kdevops-stage-2-y will be called after we've deployed all the ansible
# roles.
ifeq (,$(wildcard $(CURDIR)/.config))
else
stage-1-$(CONFIG_INSTALL_ANSIBLE_KDEVOPS)	:= kdevops_install
stage-2-$(CONFIG_INSTALL_ANSIBLE_KDEVOPS_ROLES)	+= kdevops_ansible_deps
stage-2-$(CONFIG_TERRAFORM)			+= kdevops_terraform_deps
stage-2-$(CONFIG_VAGRANT)			+= kdevops_vagrant_install_vagrant
stage-2-$(CONFIG_VAGRANT_LIBVIRT_INSTALL)	+= kdevops_vagrant_install_libvirt
stage-2-$(CONFIG_VAGRANT_LIBVIRT_CONFIGURE)	+= kdevops_vagrant_configure_libvirt
stage-2-$(CONFIG_VAGRANT)			+= kdevops_vagrant_get_Vagrantfile
stage-2-$(CONFIG_VAGRANT_INSTALL_PRIVATE_BOXES)	+= kdevops_vagrant_boxes
stage-2-$(CONFIG_VAGRANT_LIBVIRT_VERIFY)	+= kdevops_verify_vagrant_user
KDEVOPS_STAGE_2_CMD := $(MAKE) -f Makefile.kdevops $(stage-2-y)
endif

ifeq (y,$(CONFIG_FORCE_INSTALL_ANSIBLE_KDEVOPS))
export KDEVOPS_FORCE_ANSIBLE_ROLES := --force
else
export KDEVOPS_FORCE_ANSIBLE_ROLES :=
endif

KDEVOPS_BRING_UP_DEPS := /dev/null
KDEVOPS_DESTROY_DEPS := /dev/null

ifeq (y,$(CONFIG_VAGRANT))
KDEVOPS_BRING_UP_DEPS := bringup_vagrant
KDEVOPS_DESTROY_DEPS := destroy_vagrant
endif

ifeq (y,$(CONFIG_TERRAFORM))
KDEVOPS_BRING_UP_DEPS := bringup_terraform
KDEVOPS_DESTROY_DEPS := destroy_terraform
endif

export KDEVOPS_CLOUD_PROVIDER=aws
ifeq (y,$(CONFIG_TERRAFORM_AWS))
endif
ifeq (y,$(CONFIG_TERRAFORM_GCE))
export KDEVOPS_CLOUD_PROVIDER=gce
endif
ifeq (y,$(CONFIG_TERRAFORM_AZURE))
export KDEVOPS_CLOUD_PROVIDER=azure
endif
ifeq (y,$(CONFIG_TERRAFORM_OPENSTACK))
export KDEVOPS_CLOUD_PROVIDER=openstack
endif

TFVARS_TEMPLATE_DIR=terraform/templates
TFVARS_FILE_NAME=terraform.tfvars
TFVARS_FILE_POSTFIX=$(TFVARS_FILE_NAME).in

KDEVOPS_TFVARS_TEMPLATE=$(TFVARS_TEMPLATE_DIR)/$(KDEVOPS_CLOUD_PROVIDER)/$(TFVARS_FILE_POSTFIX)
KDEVOPS_TFVARS=terraform/$(KDEVOPS_CLOUD_PROVIDER)/$(TFVARS_FILE_NAME)

KDEVOS_TERRAFORM_EXTRA_DEPS :=
ifeq (y,$(CONFIG_TERRAFORM))
# For now, we only have tfvars processing support for aws
ifeq (y,$(CONFIG_TERRAFORM_AWS))
KDEVOS_TERRAFORM_EXTRA_DEPS += $(KDEVOPS_TFVARS)
endif
endif

# This will always exist, so the dependency is no set unless we have
# a key to generate.
KDEVOPS_GEN_SSH_KEY := /dev/null
KDEVOPS_REMOVE_KEY := /dev/null

ifeq (y,$(CONFIG_TERRAFORM_SSH_CONFIG_GENKEY))
export KDEVOPS_SSH_PUBKEY:=$(subst ",,$(CONFIG_TERRAFORM_SSH_CONFIG_PUBKEY_FILE))
# We have to do shell expansion. Oh, life is so hard.
export KDEVOPS_SSH_PUBKEY:=$(subst ~,$(HOME),$(KDEVOPS_SSH_PUBKEY))
export KDEVOPS_SSH_PRIVKEY:=$(basename $(KDEVOPS_SSH_PUBKEY))

ifeq (y,$(CONFIG_TERRAFORM_SSH_CONFIG_GENKEY_OVERWRITE))
KDEVOPS_REMOVE_KEY = remove-ssh-key
endif

KDEVOPS_GEN_SSH_KEY := $(KDEVOPS_SSH_PRIVKEY)
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

bringup_vagrant:
	$(Q)$(TOPDIR)/scripts/bringup_vagrant.sh

bringup_terraform:
	$(Q)$(TOPDIR)/scripts/bringup_terraform.sh

bringup: $(KDEVOPS_BRING_UP_DEPS)

destroy_vagrant:
	$(Q)$(TOPDIR)/scripts/destroy_vagrant.sh

destroy_terraform:
	$(Q)$(TOPDIR)/scripts/destroy_vagrant.sh

destroy: $(KDEVOPS_DESTROY_DEPS)

PHONY += remove-ssh-key
remove-ssh-key:
	$(NQ) Removing key pair for $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PUBKEY)

$(KDEVOPS_SSH_PRIVKEY): .config
	$(NQ) Generating new private key: $(KDEVOPS_SSH_PRIVKEY)
	$(NQ) Generating new public key: $(KDEVOPS_SSH_PUBKEY)
	$(Q)$(TOPDIR)/scripts/gen_ssh_key.sh

$(KDEVOPS_NODES): $(KDEVOPS_NODES_TEMPLATE) .config
	$(Q)$(TOPDIR)/scripts/gen_nodes_file.sh

$(KDEVOPS_TFVARS): $(KDEVOPS_TFVARS_TEMPLATE) .config
	$(Q)$(TOPDIR)/scripts/gen_tfvars.sh

PHONY += clean
clean:
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	$(Q)$(MAKE) -C terraform $@

PHONY += mrproper
mrproper:
	$(Q)$(MAKE) -f scripts/build.Makefile clean
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	$(Q)$(MAKE) -C terraform $@
	$(Q)rm -f terraform/*/terraform.tfvars
	$(Q)rm -f $(KDEVOPS_NODES)
	$(Q)rm -f .config .config.old
	$(Q)rm -rf include

PHONY += help
help:
	$(MAKE) -f scripts/build.Makefile $@

PHONY := deps
deps: \
	$(KDEVOPS_NODES) \
	$(KDEVOS_TERRAFORM_EXTRA_DEPS) \
	$(KDEVOPS_REMOVE_KEY) \
	$(KDEVOPS_GEN_SSH_KEY) \
	$(stage-1-y)
	$(Q)$(KDEVOPS_STAGE_2_CMD)

PHONY += kdevops_install
kdevops_install: $(KDEVOPS_NODES)
	$(Q)ansible-galaxy install $(KDEVOPS_FORCE_ANSIBLE_ROLES) -r requirements.yml
	$(Q)ansible-playbook -i $(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_install.yml

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)"
.PHONY: $(PHONY)
