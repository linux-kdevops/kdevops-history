# SPDX-License-Identifier: copyleft-next-0.3.1

PROJECT = kdevops
VERSION = 5
PATCHLEVEL = 0
SUBLEVEL = 2
EXTRAVERSION =

all: deps

export KCONFIG_DIR=$(CURDIR)/scripts/kconfig
include $(KCONFIG_DIR)/kconfig.Makefile
include Makefile.subtrees

export KDEVOPS_EXTRA_VARS ?=			extra_vars.yaml
export KDEVOPS_PLAYBOOKS_DIR :=			playbooks
export KDEVOPS_HOSTFILE ?=			hosts
export KDEVOPS_NODES :=
export KDEVOPS_VAGRANT :=
export PYTHONUNBUFFERED=1
export TOPDIR=./
export TOPDIR_PATH = $(shell readlink -f $(TOPDIR))

KDEVOPS_NODES_ROLE_TEMPLATE_DIR :=		$(KDEVOPS_PLAYBOOKS_DIR)/roles/gen_nodes/templates
export KDEVOPS_NODES_TEMPLATE :=
export KDEVOPS_MRPROPER :=

KDEVOPS_INSTALL_TARGETS :=

DEFAULT_DEPS :=
DEFAULT_DEPS_REQS_EXTRA_VARS :=
MAKEFLAGS += --no-print-directory
SHELL := /bin/bash
HELP_TARGETS := kconfig-help-menu
KDEVOPS_DEPCHECK = .kdevops.depcheck

PHONY += kconfig-help-menu

ifeq ($(V),1)
export Q=
export NQ=true
else
export Q=@
export NQ=echo
endif

ifneq ($(findstring 2, $(V)),)
  export ANSIBLE_VERBOSE := '-vvv'
endif

include Makefile.min_deps
DEFAULT_DEPS += $(KDEVOPS_DEPCHECK)

# This will be used to generate our extra_args.yml file used to pass on
# configuration data for ansible roles through kconfig.
EXTRA_VAR_INPUTS :=
EXTRA_VAR_INPUTS_LAST :=
ANSIBLE_EXTRA_ARGS :=
ANSIBLE_EXTRA_ARGS_SEPARATED :=
ANSIBLE_EXTRA_ARGS_DIRECT :=
include Makefile.extra_vars

LIMIT_HOSTS :=
ifneq (,$(HOSTS))
LIMIT_HOSTS := '-l $(subst ${space},$(comma),$(HOSTS))'
endif

export LIMIT_TESTS :=
ifneq (,$(TESTS))
LIMIT_TESTS := $(TESTS)
endif

INCLUDES = -I include/
CFLAGS += $(INCLUDES)

ANSIBLE_EXTRA_ARGS += kdevops_version='$(PROJECTRELEASE)'

export KDEVOPS_HOSTS_TEMPLATE := $(KDEVOPS_HOSTFILE).j2
export KDEVOPS_HOSTS := $(KDEVOPS_HOSTFILE)

LOCAL_DEVELOPMENT_ARGS	:=
ifeq (y,$(CONFIG_NEEDS_LOCAL_DEVELOPMENT_PATH))
include Makefile.local
endif # CONFIG_NEEDS_LOCAL_DEVELOPMENT_PATH

# To not clutter the top level Makefile, work which requires to be made
# on the localhost can be augmented on the LOCALHOST_SETUP_WORK variable.
# This will run after the extra_vars.yaml file is created and so you can
# rely on it. The work in LOCALHOST_SETUP_WORK is run when you just run
# make with no arguments.
LOCALHOST_SETUP_WORK :=

ANSIBLE_EXTRA_ARGS += $(LOCAL_DEVELOPMENT_ARGS)

include scripts/provision.Makefile
include scripts/systemd-timesync.Makefile
include scripts/journal-server.Makefile
include scripts/update_etc_hosts.Makefile

KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_BRING_UP_DEPS_EARLY)
KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_PROVISIONED_DEVCONFIG)

ifeq (y,$(CONFIG_WORKFLOWS))
include workflows/Makefile
endif # CONFIG_WORKFLOWS

include scripts/siw.Makefile
include scripts/ktls.Makefile
include scripts/nfsd.Makefile
include scripts/krb5.Makefile

include scripts/devconfig.Makefile
include scripts/ssh.Makefile

ANSIBLE_CMD_KOTD_ENABLE := echo KOTD disabled so not running: 
ifeq (y,$(CONFIG_WORKFLOW_KOTD_ENABLE))
include scripts/kotd.Makefile
endif # WORKFLOW_KOTD_ENABLE

# We may not need the extra_args.yaml file all the time.  If this file is empty
# you don't need it. All of our ansible kdevops roles check for this file
# without you having to specify it as an extra_args=@extra_args.yaml file. This
# helps us with allowing users call ansible on the command line themselves,
# instead of using the make constructs we have built here.
ifneq (,$(ANSIBLE_EXTRA_ARGS))
DEFAULT_DEPS += $(KDEVOPS_EXTRA_VARS)
endif

ifeq (y,$(CONFIG_VAGRANT))
DEFAULT_DEPS += $(KDEVOPS_VAGRANT)
endif

DEFAULT_DEPS += $(DEFAULT_DEPS_REQS_EXTRA_VARS)

include scripts/install-menuconfig-deps.Makefile

include Makefile.btrfs_progs

ifeq (y,$(CONFIG_QEMU_BUILD))
include Makefile.build_qemu
endif # CONFIG_QEMU_BUILD

ifeq (y,$(CONFIG_SETUP_POSTFIX_EMAIL_RELAY))
include Makefile.postfix
endif # CONFIG_SETUP_POSTFIX_EMAIL_RELAY

ifeq (y,$(CONFIG_HYPERVISOR_TUNING))
include Makefile.hypervisor-tunings
endif # CONFIG_HYPERVISOR_TUNING

include Makefile.linux-mirror

ifeq (y,$(CONFIG_KDEVOPS_DISTRO_REG_METHOD_TWOLINE))
DEFAULT_DEPS += playbooks/secret.yml
endif

ifeq (y,$(CONFIG_KDEVOPS_ENABLE_DISTRO_EXTRA_ADDONS))
KDEVOPS_EXTRA_ADDON_SOURCE:=$(subst ",,$(CONFIG_KDEVOPS_EXTRA_ADDON_SOURCE))
endif

KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK:=$(subst ",,$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK))
ifeq (y,$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_ENABLE))
ANSIBLE_EXTRA_ARGS += kdevops_ansible_provision_playbook='$(KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK)'

KDEVOPS_DEVCONFIG_CUSTOM_REPOS:=$(subst ",,$(CONFIG_KDEVOPS_DEVCONFIG_CUSTOM_REPOS))
ANSIBLE_EXTRA_ARGS += kdevops_devconfig_custom_repos='$(KDEVOPS_DEVCONFIG_CUSTOM_REPOS)'

KDEVOPS_DEVCONFIG_CUSTOM_PACKAGES:=$(subst ",,$(CONFIG_KDEVOPS_DEVCONFIG_CUSTOM_PACKAGES))
ANSIBLE_EXTRA_ARGS += kdevops_devconfig_custom_packages='$(KDEVOPS_DEVCONFIG_CUSTOM_PACKAGES)'

endif

include scripts/gen-hosts.Makefile
include scripts/gen-nodes.Makefile

# disable built-in rules for this
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

PHONY += $(EXTRA_VAR_INPUTS) $(EXTRA_VAR_INPUTS_LAST)

$(KDEVOPS_EXTRA_VARS): .config $(EXTRA_VAR_INPUTS) $(EXTRA_VAR_INPUTS_LAST)

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

KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_BRING_UP_LATE_DEPS)

ifneq (,$(KDEVOPS_BRING_UP_DEPS))
include scripts/bringup.Makefile
endif

DEFAULT_DEPS += $(KDEVOPS_HOSTS)
$(KDEVOPS_HOSTS): .config $(KDEVOPS_HOSTS_TEMPLATE)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/gen_hosts.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		--extra-vars=@./extra_vars.yaml

DEFAULT_DEPS += $(KDEVOPS_NODES)
$(KDEVOPS_NODES) $(KDEVOPS_VAGRANT): .config $(KDEVOPS_NODES_TEMPLATE)
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/gen_nodes.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		--extra-vars=@./extra_vars.yaml

DEFAULT_DEPS += $(LOCALHOST_SETUP_WORK)

include scripts/tests.Makefile

PHONY += clean
clean:
	$(Q)$(MAKE) -f scripts/build.Makefile $@

version-check:
	$(Q)$(MAKE) -f scripts/build.Makefile $@

PHONY += mrproper
mrproper:
	$(Q)$(MAKE) -f scripts/build.Makefile clean
	$(Q)$(MAKE) -f scripts/build.Makefile $@
	$(Q)rm -f $(KDEVOPS_DEPCHECK)
	$(Q)rm -f terraform/*/terraform.tfvars
	$(Q)rm -f $(KDEVOPS_NODES)
	$(Q)rm -f $(KDEVOPS_HOSTFILE) $(KDEVOPS_MRPROPER)
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
deps: $(DEFAULT_DEPS)

PHONY += install
install: $(KDEVOPS_INSTALL_TARGETS)
	$(Q)echo   Installed

.PHONY: $(PHONY)
