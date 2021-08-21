# SPDX-License-Identifier: copyleft-next-0.3.1

PROJECT = kdevops
VERSION = 4
PATCHLEVEL = 3
SUBLEVEL = 3
EXTRAVERSION =

export KDEVOPS_EXTRA_VARS ?=			extra_vars.yaml
export KDEVOPS_PLAYBOOKS_DIR :=			playbooks
export KDEVOPS_HOSTFILE ?=			hosts
export KDEVOPS_NODES :=				vagrant/kdevops_nodes.yaml
export PYTHONUNBUFFERED=1

KDEVOPS_NODES_TEMPLATES :=			workflows/linux/kdevops_nodes_split_start.yaml.in
export KDEVOPS_NODES_TEMPLATES

export KDEVOPS_FSTESTS_CONFIG :=
export KDEVOPS_FSTESTS_CONFIG_TEMPLATE :=

export KDEVOPS_BLKTESTS_CONFIG :=
export KDEVOPS_BLKTESTS_CONFIG_TEMPLATE :=

KDEVOPS_INSTALL_TARGETS :=

all: deps

MAKEFLAGS += --no-print-directory
SHELL := /bin/bash
HELP_TARGETS := kconfig-help-menu
PHONY += kconfig-help-menu

ifeq ($(V),1)
export Q=
export NQ=true
else
export Q=@
export NQ=echo
endif

# This will always exist, so the dependency is no set unless we have
# a key to generate.
KDEVOPS_GEN_SSH_KEY :=
KDEVOPS_REMOVE_KEY :=

include Makefile.subtrees
include scripts/kconfig.Makefile
INCLUDES = -I include/
CFLAGS += $(INCLUDES)

export KDEVOPS_HOSTS_TEMPLATE := $(KDEVOPS_HOSTFILE).in
export KDEVOPS_HOSTS := $(KDEVOPS_HOSTFILE)

# This will be used to generate our extra_args.yml file used to pass on
# configuration data for ansible roles through kconfig.
ANSIBLE_EXTRA_ARGS :=

# These should be set as non-empty if you want any generic bring up
# targets to come up. We support 2 bring up methods:
#
#  - vagrant: for kvm/virtualbox
#  - terraform: for any cloud provider
#
# If you are using bare metal, you don't do bring up, or you'd
# likely do this yourself. What you *might* need if working
# with bare metal is provisioning, but our workflows targets
# provide that. The devconfig ansible role can be also augmented
# to support many different custom provisioning preferences outside
# of the scope of workflows. With things like kdump, etc.
KDEVOPS_BRING_UP_DEPS :=
KDEVOPS_DESTROY_DEPS :=

KDEVOS_TERRAFORM_EXTRA_DEPS :=
ifeq (y,$(CONFIG_TERRAFORM))
include scripts/terraform.Makefile
endif # CONFIG_TERRAFORM

ifeq (y,$(CONFIG_VAGRANT))
include scripts/vagrant.Makefile
endif

WORKFLOW_ARGS	:=
ifeq (y,$(CONFIG_WORKFLOWS))
include workflows/Makefile
endif # CONFIG_WORKFLOWS

ANSIBLE_EXTRA_ARGS += $(WORKFLOW_ARGS)

ifeq (y,$(CONFIG_HAVE_DISTRO_REQUIRES_CUSTOM_SSH_KEXALGORITHMS))
SSH_KEXALGORITHMS:=$(subst ",,$(CONFIG_KDEVOPS_CUSTOM_SSH_KEXALGORITHMS))
ANSIBLE_EXTRA_ARGS += use_kexalgorithms=True
ANSIBLE_EXTRA_ARGS += kexalgorithms=$(SSH_KEXALGORITHMS)
endif

include scripts/devconfig.Makefile

ifeq (y,$(CONFIG_KDEVOPS_SSH_CONFIG_UPDATE))
SSH_CONFIG_FILE:=$(subst ",,$(CONFIG_KDEVOPS_SSH_CONFIG))
ANSIBLE_EXTRA_ARGS += sshconfig=$(CONFIG_KDEVOPS_SSH_CONFIG)
endif

ANSIBLE_CMD_KOTD_ENABLE := echo KOTD disabled so not running: 
ifeq (y,$(CONFIG_WORKFLOW_KOTD_ENABLE))
include scripts/kotd.Makefile
endif # WORKFLOW_KOTD_ENABLE

KDEVOPS_HOSTS_PREFIX:=$(subst ",,$(CONFIG_KDEVOPS_HOSTS_PREFIX))
ANSIBLE_EXTRA_ARGS += kdevops_host_prefix=$(KDEVOPS_HOSTS_PREFIX)

# We may not need the extra_args.yaml file all the time.  If this file is empty
# you don't need it. All of our ansible kdevops roles check for this file
# without you having to specify it as an extra_args=@extra_args.yaml file. This
# helps us with allowing users call ansible on the command line themselves,
# instead of using the make constructs we have built here.
ifneq (,$(ANSIBLE_EXTRA_ARGS))
EXTRA_ARGS_BUILD_DEP := $(KDEVOPS_EXTRA_VARS)
else
EXTRA_ARGS_BUILD_DEP :=
endif

ifeq (y,$(CONFIG_KDEVOPS_DISTRO_REG_METHOD_TWOLINE))
KDEVOPS_TWOLINE_REGMETHOD_DEPS := playbooks/secret.yml
else
KDEVOPS_TWOLINE_REGMETHOD_DEPS :=
endif

ifeq (y,$(CONFIG_KDEVOPS_ENABLE_DISTRO_EXTRA_ADDONS))
KDEVOPS_EXTRA_ADDON_SOURCE:=$(subst ",,$(CONFIG_KDEVOPS_EXTRA_ADDON_SOURCE))
endif

KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK:=$(subst ",,$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK))

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
	make -f scripts/build.Makefile help                             ;\
	false)

define YAML_ENTRY
$(1)

endef

$(KDEVOPS_EXTRA_VARS): .config
	@echo --- > $(KDEVOPS_EXTRA_VARS)
	@$(foreach exp,$(ANSIBLE_EXTRA_ARGS),echo $(call YAML_ENTRY,$(subst =,: ,$(exp)) >> $(KDEVOPS_EXTRA_VARS)))
	@if [[ "$(CONFIG_HAVE_VAGRANT_BOX_URL)" == "y" ]]; then \
		echo "kdevops_install_vagrant_boxes: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "vagrant_boxes:" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "  - { name: '$(CONFIG_VAGRANT_BOX)', box_url: '$(CONFIG_VAGRANT_BOX_URL)' }" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_ENABLE_DISTRO_EXTRA_ADDONS)" == "y" ]]; then \
		echo "devconfig_repos_addon: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		cat $(KDEVOPS_EXTRA_ADDON_SOURCE) >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_DEVCONFIG_ENABLE_CONSOLE)" == "y" ]]; then \
		echo "devconfig_kernel_console: '$(CONFIG_KDEVOPS_DEVCONFIG_KERNEL_CONSOLE_SETTINGS)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_grub_console: '$(CONFIG_KDEVOPS_DEVCONFIG_GRUB_SERIAL_COMMAND)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_DEVCONFIG_ENABLE_SYSTEMD_WATCHDOG)" == "y" ]]; then \
		echo "devconfig_systemd_watchdog_runtime_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_RUNTIME)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_systemd_watchdog_reboot_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_REBOOT)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_systemd_watchdog_kexec_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_KEXEC)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS)" == "y" ]]; then \
		echo "blktests_test_devs: '$(CONFIG_BLKTESTS_TEST_DEVS)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi

playbooks/secret.yml:
	@if [[ "$(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE)" == "" ]]; then \
		echo "Registration code is not set, this must be set for this configuration" ;\
		exit 1 ;\
	fi
	@echo --- > $@
	@echo "$(CONFIG_KDEVOPS_REG_TWOLINE_ENABLE_STRING): True" >> $@
	@echo "$(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE_VAR): $(CONFIG_KDEVOPS_REG_TWOLINE_REGCODE)" >> $@

ifeq (y,$(CONFIG_KDEVOPS_ENABLE_DISTRO_EXTRA_ADDONS))
$(KDEVOPS_EXTRA_ADDON_DEST): .config $(KDEVOPS_EXTRA_ADDON_SOURCE)
	@$(Q)cp $(KDEVOPS_EXTRA_ADDON_SOURCE) $(KDEVOPS_EXTRA_ADDON_DEST)
endif

ifneq (,$(KDEVOPS_BRING_UP_DEPS))
include scripts/bringup.Makefile
endif

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
	@$(Q)if [ -f terraform/Makefile ]; then \
		$(MAKE) -C terraform/ $@ ;\
	fi

PHONY += mrproper
mrproper:
	$(Q)$(MAKE) -f scripts/build.Makefile clean
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	@$(Q)if [ -f terraform/Makefile ]; then \
		$(MAKE) -C terraform clean ;\
	fi
	$(Q)rm -f terraform/*/terraform.tfvars
	$(Q)rm -f $(KDEVOPS_NODES)
	$(Q)rm -f $(KDEVOPS_HOSTFILE) $(KDEVOPS_WORKFLOW_FSTESTS_CLEAN)
	$(Q)rm -f .config .config.old extra_vars.yaml
	$(Q)rm -f playbooks/secret.yml $(KDEVOPS_EXTRA_ADDON_DEST)
	$(Q)rm -rf include

kconfig-help-menu:
	$(Q)$(MAKE) -s -C scripts/kconfig help
	$(Q)$(MAKE) -f scripts/build.Makefile help

PHONY += $(HELP_TARGETS)

PHONY += help
help: $(HELP_TARGETS)

PHONY += deps
deps: \
	$(EXTRA_ARGS_BUILD_DEP) \
	$(KDEVOPS_TWOLINE_REGMETHOD_DEPS) \
	$(KDEVOPS_HOSTS) \
	$(KDEVOPS_NODES) \
	$(KDEVOS_TERRAFORM_EXTRA_DEPS) \
	$(KDEVOPS_REMOVE_KEY) \
	$(KDEVOPS_GEN_SSH_KEY) \
	$(KDEVOPS_FSTESTS_CONFIG) \
	$(KDEVOPS_STAGE_2_DEPS)

PHONY += install
install: $(KDEVOPS_INSTALL_TARGETS)
	$(Q)echo   Installed

PHONY += linux
linux: $(KDEVOPS_NODES)
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/bootlinux.yml \
		--extra-vars="$(BOOTLINUX_ARGS)"
.PHONY: $(PHONY)
