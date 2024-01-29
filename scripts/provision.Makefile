# SPDX-License-Identifier: copyleft-next-0.3.1

# Provisioning methods should set this to their target which will ensure
# systems will be up after this.
KDEVOPS_PROVISION_METHOD :=

# Provisioning methods should set this to their target which will ensure
# the systems will be removed after this
KDEVOPS_PROVISION_DESTROY_METHOD :=

# The default guard for ssh provisioning. Provisioning methods can set the
# KDEVOPS_PROVISIONED_SSH to this if they are OK with the default guard.
KDEVOPS_PROVISIONED_SSH_DEFAULT_GUARD := .provisioned_once_ssh

# This is empty on purpose so to support terraform which does this for us
# on the terraform provider and bare metal where it is assumed you already
# have ssh setup. Later we can grow this for other bare metal setups or to
# consume / gather existing topologies. To be clear, terraform providers are
# in charge of figuring out ssh configuration updates for you in kdevops.
KDEVOPS_PROVISIONED_SSH :=

# You should augment this with targets which should be after ssh is
# ready to go to each node, and before devconfig playbook is run.
# The devconfig playbook can be used with tags to ensure deps / setup
# for early deps are run.
KDEVOPS_BRING_UP_DEPS_EARLY  :=

# This is shared task.
KDEVOPS_PROVISIONED_DEVCONFIG := .provisioned_once_devconfig

KDEVOPS_BRING_UP_DEPS :=
KDEVOPS_DESTROY_DEPS :=

# These go last
KDEVOPS_BRING_UP_LATE_DEPS :=

include scripts/dynamic-kconfig.Makefile

ifeq (y,$(CONFIG_TERRAFORM))
include scripts/terraform.Makefile
endif # CONFIG_TERRAFORM

ifeq (y,$(CONFIG_VAGRANT))
include scripts/vagrant.Makefile
endif

ifeq (y,$(CONFIG_GUESTFS))
include scripts/guestfs.Makefile
endif

KDEVOPS_MRPROPER += $(KDEVOPS_PROVISIONED_SSH)
KDEVOPS_MRPROPER += $(KDEVOPS_PROVISIONED_DEVCONFIG)

$(KDEVOPS_PROVISIONED_DEVCONFIG):
	$(Q)if [[ "$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK)" != "" ]]; then \
		ansible-playbook $(ANSIBLE_VERBOSE) -i \
			$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/$(KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK) ;\
	fi
	$(Q)touch $(KDEVOPS_PROVISIONED_DEVCONFIG)

# Provisioning split into 4 steps:
#
# 1) Provisioning method, if one is defined
# 2) Ensuring we can use ansible with ssh, if required
# 3) Installing early dependencies, if any, which independent of any workflow
# 4) Optionally run the devconfig playbook for configuration (which may include
#    extra tools)
#
# The last two are dealt with in the top level Makefile so to allow us to
# define early dependencies from the top level Makefile and make it clear
# that the devconfig playbook runs last.
#
# Anything deps after this is dealt with on each respective workflow.
KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_PROVISION_METHOD)
KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_PROVISIONED_SSH)

KDEVOPS_DESTROY_DEPS += $(KDEVOPS_PROVISION_DESTROY_METHOD)
