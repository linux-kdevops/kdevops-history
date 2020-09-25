# SPDX-License-Identifier: GPL-2.0
#
PROJECT = kdevops
VERSION = 3
PATCHLEVEL = 3
SUBLEVEL = 4
EXTRAVERSION = rc1

export KDEVOPS_EXTRA_VARS ?=			extra_vars.yaml
export KDEVOPS_PLAYBOOKS_DIR :=			playbooks
export KDEVOPS_HOSTFILE ?=			hosts
export KDEVOPS_NODES :=				vagrant/kdevops_nodes.yaml

KDEVOPS_NODES_TEMPLATES :=			workflows/linux/kdevops_nodes_split_start.yaml.in
KDEVOPS_NODES_TEMPLATES +=			workflows/linux/kdevops_nodes_split_end.yaml.in
export KDEVOPS_NODES_TEMPLATES

export KDEVOPS_FSTESTS_CONFIG :=
export KDEVOPS_FSTESTS_CONFIG_TEMPLATE :=

KDEVOPS_INSTALL_TARGETS :=

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

export KDEVOPS_HOSTS_TEMPLATE := $(KDEVOPS_HOSTFILE).in
export KDEVOPS_HOSTS := $(KDEVOPS_HOSTFILE)

# This will be used to generate our extra_args.yml file used to pass on
# configuration data for ansible roles through kconfig.
ANSIBLE_EXTRA_ARGS :=

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

KDEVOPS_BRING_UP_DEPS :=
KDEVOPS_DESTROY_DEPS :=

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

ifeq (y,$(CONFIG_TERRAFORM_AWS))
KDEVOS_TERRAFORM_EXTRA_DEPS += $(KDEVOPS_TFVARS)
endif

ifeq (y,$(CONFIG_TERRAFORM_AZURE))
KDEVOS_TERRAFORM_EXTRA_DEPS += $(KDEVOPS_TFVARS)
endif

ifeq (y,$(CONFIG_TERRAFORM_GCE))
KDEVOS_TERRAFORM_EXTRA_DEPS += $(KDEVOPS_TFVARS)
endif

ifeq (y,$(CONFIG_TERRAFORM_OPENSTACK))
KDEVOS_TERRAFORM_EXTRA_DEPS += $(KDEVOPS_TFVARS)
endif

endif # CONFIG_TERRAFORM

# This will always exist, so the dependency is no set unless we have
# a key to generate.
KDEVOPS_GEN_SSH_KEY :=
KDEVOPS_REMOVE_KEY :=

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

WORKFLOW_ARGS	:=
ifeq (y,$(CONFIG_WORKFLOWS))
# How we create the partition for the workflow data partition
WORKFLOW_DATA_DEVICE:=$(subst ",,$(CONFIG_WORKFLOW_DATA_DEVICE))
WORKFLOW_DATA_PATH:=$(subst ",,$(CONFIG_WORKFLOW_DATA_PATH))
WORKFLOW_DATA_FSTYPE:=$(subst ",,$(CONFIG_WORKFLOW_DATA_FSTYPE))
WORKFLOW_DATA_LABEL:=$(subst ",,$(CONFIG_WORKFLOW_DATA_LABEL))

WORKFLOW_KDEVOPS_GIT:=$(subst ",,$(CONFIG_WORKFLOW_KDEVOPS_GIT))
WORKFLOW_KDEVOPS_GIT_DATA:=$(subst ",,$(CONFIG_WORKFLOW_KDEVOPS_GIT_DATA))

WORKFLOW_ARGS	+= data_device=$(WORKFLOW_DATA_DEVICE)
WORKFLOW_ARGS	+= data_path=$(WORKFLOW_DATA_PATH)
WORKFLOW_ARGS	+= data_fstype=$(WORKFLOW_DATA_FSTYPE)
WORKFLOW_ARGS	+= data_label=$(WORKFLOW_DATA_LABEL)
WORKFLOW_ARGS	+= kdevops_git=$(WORKFLOW_KDEVOPS_GIT)
WORKFLOW_ARGS	+= kdevops_data=\"$(WORKFLOW_KDEVOPS_GIT_DATA)\"

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE))

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE_POSTFIX))
WORKFLOW_ARGS	+= fstests_extra_install_postfix=True
endif # CONFIG_WORKFLOW_EXTRA_SOFTWARE_POSTFIX

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE_WATCHDOG))
WORKFLOW_ARGS	+= fstests_extra_install_watchdog=True
endif # CONFIG_WORKFLOW_EXTRA_SOFTWARE_WATCHDOG

endif # CONFIG_WORKFLOW_EXTRA_SOFTWARE

ifeq (y,$(CONFIG_WORKFLOW_MAKE_CMD_OVERRIDE))
WORKFLOW_MAKE_CMD:=$(subst ",,$(CONFIG_WORKFLOW_MAKE_CMD))
endif

ifeq (y,$(CONFIG_WORKFLOW_INFER_USER_AND_GROUP))
WORKFLOW_ARGS	+= infer_uid_and_group=True
else
WORKFLOW_DATA_USER:=$(subst ",,$(CONFIG_WORKFLOW_DATA_USER))
WORKFLOW_DATA_GROUP:=$(subst ",,$(CONFIG_WORKFLOW_DATA_GROUP))

WORKFLOW_ARGS	+= data_user=$(WORKFLOW_DATA_USER)
WORKFLOW_ARGS	+= data_group=$(WORKFLOW_DATA_GROUP)

endif # CONFIG_WORKFLOW_MAKE_CMD_OVERRIDE == y

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE))

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE_POSTFIX))
WORKFLOW_ARGS += workflow_install_postfix=true
else
WORKFLOW_ARGS += workflow_install_postfix=false
endif # CONFIG_WORKFLOW_EXTRA_SOFTWARE_POSTFIX

ifeq (y,$(CONFIG_WORKFLOW_EXTRA_SOFTWARE_WATCHDOG))
WORKFLOW_ARGS += workflow_install_watchdog=true
else
WORKFLOW_ARGS += workflow_install_watchdog=false
endif # WORKFLOW_EXTRA_SOFTWARE_WATCHDOG

endif # CONFIG_WORKFLOW_EXTRA_SOFTWARE

BOOTLINUX_ARGS	:=
ifeq (y,$(CONFIG_BOOTLINUX))
TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_NAME:=$(subst .git,,$(TREE_NAME))
TREE_VERSION:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_VERSION))
TREE_CONFIG:=config-$(TREE_VERSION)

# Describes the Linux clone
BOOTLINUX_ARGS	+= target_linux_git=$(TREE_URL)
BOOTLINUX_ARGS	+= target_linux_tree=$(TREE_NAME)
BOOTLINUX_ARGS	+= target_linux_tag=$(TREE_VERSION)
BOOTLINUX_ARGS	+= target_linux_config=$(TREE_CONFIG)

ifeq (y,$(CONFIG_WORKFLOW_MAKE_CMD_OVERRIDE))
BOOTLINUX_ARGS	+= target_linux_make_cmd='$(WORKFLOW_MAKE_CMD)'
endif

WORKFLOW_ARGS += $(BOOTLINUX_ARGS)
endif # CONFIG_BOOTLINUX == y

KDEVOPS_WORKFLOW_FSTESTS_CLEAN :=

ifeq (y,$(CONFIG_KDEVOPS_WORKFLOW_FSTESTS))
include workflows/fstests/Makefile
endif # CONFIG_KDEVOPS_WORKFLOW_FSTESTS == y

endif # CONFIG_WORKFLOWS

ANSIBLE_EXTRA_ARGS += $(WORKFLOW_ARGS)

ifeq (y,$(CONFIG_TERRAFORM))
SSH_CONFIG_USER:=$(subst ",,$(CONFIG_TERRAFORM_SSH_CONFIG_USER))
# XXX: add support to auto-infer in devconfig role as we did with the bootlinux
# role. Then we can re-use the same infer_uid_and_group=True variable and
# we could then remove this entry.
ANSIBLE_EXTRA_ARGS += data_home_dir=/home/${SSH_CONFIG_USER}
endif

# We don't need the extra_args.yaml file all the time. *If* we know
# we have changed a default variable though we can extend the arguments
# on ANSIBLE_EXTRA_ARGS and all these will be used to create the file
# for you. If this file is empty you don't need it. All of our ansible
# kdevops roles check for this file without you having to specify it as
# an extra_args=@extra_args.yaml file. This helps us with allowing users
# call ansible on the command line themselves, instead of using the make
# constructs we have built here.
ifneq (,$(ANSIBLE_EXTRA_ARGS))
EXTRA_ARGS_BUILD_DEP := $(KDEVOPS_EXTRA_VARS)
else
EXTRA_ARGS_BUILD_DEP :=
endif

ifeq (y,$(CONFIG_HAVE_VAGRANT_BOX_URL))
VAGRANT_PRIVATE_BOX_DEPS := vagrant_private_box_install
else
VAGRANT_PRIVATE_BOX_DEPS :=
endif

ifeq (y,$(CONFIG_KDEVOPS_DISTRO_REG_METHOD_TWOLINE))
KDEVOPS_TWOLINE_REGMETHOD_DEPS := playbooks/secret.yml
else
KDEVOPS_TWOLINE_REGMETHOD_DEPS :=
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

define YAML_ENTRY
$(1)$(2)$(3)$(4)$(5)$(6)$(7)

endef

$(KDEVOPS_EXTRA_VARS): .config
	@echo --- > $(KDEVOPS_EXTRA_VARS)
	@$(foreach exp,$(ANSIBLE_EXTRA_ARGS),echo $(call YAML_ENTRY,$(subst =,: ,$(exp)) >> $(KDEVOPS_EXTRA_VARS)))
	@if [[ "$(CONFIG_HAVE_VAGRANT_BOX_URL)" == "y" ]]; then \
		echo "kdevops_install_vagrant_boxes: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "vagrant_boxes:" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "  - { name: '$(CONFIG_VAGRANT_BOX)', box_url: '$(CONFIG_VAGRANT_BOX_URL)' }" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi

playbooks/secret.yml:
	@if [[ "$(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE)" == "" ]]; then \
		echo "Registration code is not set, this must be set for this configuration" ;\
		exit 1 ;\
	fi
	@echo --- > $@
	@echo "$(CONFIG_KDEVOPS_REG_TWOLINE_ENABLE_STRING): True" >> $@
	@echo "$(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE_VAR): $(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE)" >> $@

vagrant_private_box_install:
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/install-vagrant-boxes.yml

bringup_vagrant: $(VAGRANT_PRIVATE_BOX_DEPS)
	$(Q)$(TOPDIR)/scripts/bringup_vagrant.sh
	$(Q)ansible-playbook --connection=local \
		--inventory localhost, \
		playbooks/update_ssh_config_vagrant.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

bringup_terraform:
	$(Q)$(TOPDIR)/scripts/bringup_terraform.sh

bringup: $(KDEVOPS_BRING_UP_DEPS)

destroy_vagrant:
	$(Q)$(TOPDIR)/scripts/destroy_vagrant.sh

destroy_terraform:
	$(Q)$(TOPDIR)/scripts/destroy_terraform.sh

destroy: $(KDEVOPS_DESTROY_DEPS)

$(KDEVOPS_HOSTS): .config $(KDEVOPS_HOSTS_TEMPLATE)
	$(Q)$(TOPDIR)/scripts/gen_hosts.sh

PHONY += remove-ssh-key
remove-ssh-key:
	$(NQ) Removing key pair for $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PUBKEY)

$(KDEVOPS_SSH_PRIVKEY): .config
	$(NQ) Generating new private key: $(KDEVOPS_SSH_PRIVKEY)
	$(NQ) Generating new public key: $(KDEVOPS_SSH_PUBKEY)
	$(Q)$(TOPDIR)/scripts/gen_ssh_key.sh

$(KDEVOPS_NODES): $(KDEVOPS_NODES_TEMPLATES) .config
	$(Q)$(TOPDIR)/scripts/gen_nodes_file.sh

$(KDEVOPS_TFVARS): $(KDEVOPS_TFVARS_TEMPLATE) .config
	$(Q)$(TOPDIR)/scripts/gen_tfvars.sh

PHONY += clean
clean:
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	@if [ -f terraform/Makefile ]; then \
		$(MAKE) -C terraform/ $@ ;\
	fi

PHONY += mrproper
mrproper:
	$(Q)$(MAKE) -f scripts/build.Makefile clean
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	@if [ -f terraform/Makefile ]; then \
		$(MAKE) -C terraform clean ;\
	fi
	$(Q)rm -f terraform/*/terraform.tfvars
	$(Q)rm -f $(KDEVOPS_NODES)
	$(Q)rm -f $(KDEVOPS_HOSTFILE) $(KDEVOPS_WORKFLOW_FSTESTS_CLEAN)
	$(Q)rm -f .config .config.old
	$(Q)rm -f playbooks/secret.yml
	$(Q)rm -rf include

PHONY += help
help:
	$(MAKE) -f scripts/build.Makefile $@

PHONY := deps
deps: \
	$(EXTRA_ARGS_BUILD_DEP) \
	$(KDEVOPS_TWOLINE_REGMETHOD_DEPS) \
	$(KDEVOPS_HOSTS) \
	$(KDEVOPS_NODES) \
	$(KDEVOS_TERRAFORM_EXTRA_DEPS) \
	$(KDEVOPS_REMOVE_KEY) \
	$(KDEVOPS_GEN_SSH_KEY) \
	$(KDEVOPS_FSTESTS_CONFIG) \
	$(stage-1-y)
	$(Q)$(KDEVOPS_STAGE_2_CMD)

PHONY += kdevops_install
kdevops_install: $(KDEVOPS_NODES)
	$(Q)ansible-galaxy install $(KDEVOPS_FORCE_ANSIBLE_ROLES) -r requirements.yml
	$(Q)ansible-playbook -i $(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_install.yml

PHONY += install
install: $(KDEVOPS_INSTALL_TARGETS)
	$(Q)echo   Installed

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)"
.PHONY: $(PHONY)
