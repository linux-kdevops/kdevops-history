# SPDX-License-Identifier: copyleft-next-0.3.1

TOPDIR_PATH = $(shell readlink -f $(TOPDIR))
KDEVOPS_PLAYBOOKS_DIR_FULL_PATH=$(TOPDIR_PATH)/$(KDEVOPS_PLAYBOOKS_DIR)/
KDEVOPS_HOSTS_TEMPLATE_DIR=$(KDEVOPS_PLAYBOOKS_DIR_FULL_PATH)/roles/gen_hosts/templates/

GENHOSTS_EXTRA_ARGS += topdir_path='$(TOPDIR_PATH)'
GENHOSTS_EXTRA_ARGS += kdevops_playbooks_dir='$(KDEVOPS_PLAYBOOKS_DIR)'
GENHOSTS_EXTRA_ARGS += kdevops_hosts='$(KDEVOPS_HOSTFILE)'

# Relative path so that ansible can work with it
KDEVOPS_HOSTS_TEMPLATE_SHORT:=$(KDEVOPS_HOSTS_TEMPLATE)
GENHOSTS_EXTRA_ARGS += kdevops_hosts_template='$(KDEVOPS_HOSTS_TEMPLATE_SHORT)'

# Now override this variable so Make knows where to look
KDEVOPS_HOSTS_TEMPLATE:=$(KDEVOPS_HOSTS_TEMPLATE_DIR)/$(KDEVOPS_HOSTS_TEMPLATE)
GENHOSTS_EXTRA_ARGS += kdevops_hosts_template_full_path='$(KDEVOPS_HOSTS_TEMPLATE)'

GENHOSTS_EXTRA_ARGS += kdevops_playbooks_dir_full_path='$(KDEVOPS_PLAYBOOKS_DIR_FULL_PATH)'
GENHOSTS_EXTRA_ARGS += kdevops_genhosts_templates_dir='$(KDEVOPS_HOSTS_TEMPLATE_DIR)'
GENHOSTS_EXTRA_ARGS += kdevops_hosts_prefix='$(CONFIG_KDEVOPS_HOSTS_PREFIX)'
GENHOSTS_EXTRA_ARGS += kdevops_python_interpreter='$(CONFIG_KDEVOPS_PYTHON_INTERPRETER)'
GENHOSTS_EXTRA_ARGS += kdevops_python_old_interpreter='$(CONFIG_KDEVOPS_PYTHON_OLD_INTERPRETER)'
ifeq (y,$(CONFIG_KDEVOPS_BASELINE_AND_DEV))
GENHOSTS_EXTRA_ARGS += kdevops_baseline_and_dev='True'
endif

ifeq (y,$(CONFIG_WORKFLOWS_DEDICATED_WORKFLOW))
GENHOSTS_EXTRA_ARGS += kdevops_workflows_dedicated_workflow='True'
endif

ANSIBLE_EXTRA_ARGS += $(GENHOSTS_EXTRA_ARGS)
