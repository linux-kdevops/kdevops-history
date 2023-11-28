# SPDX-License-Identifier: copyleft-next-0.3.1

GUESTFS_ARGS :=

KDEVOPS_NODES_TEMPLATE :=	$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/guestfs_nodes.j2
KDEVOPS_NODES :=		guestfs/kdevops_nodes.yaml

export KDEVOPS_GUESTFS_PROVISIONED :=	guestfs/.provisioned_once

KDEVOPS_MRPROPER +=		$(KDEVOPS_GUESTFS_PROVISIONED)

GUESTFS_ARGS += kdevops_enable_guestfs=True
GUESTFS_ARGS += guestfs_path='$(TOPDIR_PATH)/guestfs'
GUESTFS_ARGS += data_home_dir=/home/kdevops
GUESTFS_ARGS += virtbuilder_os_version=$(CONFIG_VIRT_BUILDER_OS_VERSION)
GUESTFS_ARGS += kdevops_storage_pool_user='$(USER)'

GUESTFS_ARGS += libvirt_provider=True

QEMU_GROUP:=$(subst ",,$(CONFIG_LIBVIRT_QEMU_GROUP))
GUESTFS_ARGS += kdevops_storage_pool_group='$(QEMU_GROUP)'
GUESTFS_ARGS += storage_pool_group='$(QEMU_GROUP)'

STORAGE_POOL_PATH:=$(subst ",,$(CONFIG_KDEVOPS_STORAGE_POOL_PATH))
KDEVOPS_STORAGE_POOL_PATH:=$(STORAGE_POOL_PATH)/kdevops
GUESTFS_ARGS += storage_pool_path=$(STORAGE_POOL_PATH)
GUESTFS_ARGS += kdevops_storage_pool_path=$(KDEVOPS_STORAGE_POOL_PATH)

9P_HOST_CLONE :=
ifeq (y,$(CONFIG_BOOTLINUX_9P))
9P_HOST_CLONE := 9p_linux_clone
endif

LIBVIRT_PCIE_PASSTHROUGH :=
ifeq (y,$(CONFIG_KDEVOPS_LIBVIRT_PCIE_PASSTHROUGH))
LIBVIRT_PCIE_PASSTHROUGH := libvirt_pcie_passthrough_permissions
endif

ifneq ($(strip $(CONFIG_RHEL_ORG_ID)),)
ifneq ($(strip $(CONFIG_RHEL_ACTIVATION_KEY)),)
RHEL_ORG_ID:=$(subst ",,$(CONFIG_RHEL_ORG_ID))
RHEL_ACTIVATION_KEY:=$(subst ",,$(CONFIG_RHEL_ACTIVATION_KEY))
GUESTFS_ARGS += rhel_org_id="$(RHEL_ORG_ID)"
GUESTFS_ARGS += rhel_activation_key="$(RHEL_ACTIVATION_KEY)"
endif
endif

ANSIBLE_EXTRA_ARGS += $(GUESTFS_ARGS)

GUESTFS_BRINGUP_DEPS :=
GUESTFS_BRINGUP_DEPS +=  $(9P_HOST_CLONE)
GUESTFS_BRINGUP_DEPS +=  $(LIBVIRT_PCIE_PASSTHROUGH)

KDEVOPS_BRING_UP_DEPS := bringup_guestfs
KDEVOPS_DESTROY_DEPS := destroy_guestfs

# Provisioning goes last
KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_GUESTFS_PROVISIONED)

9p_linux_clone:
	$(Q)make linux-clone

libvirt_pcie_passthrough_permissions:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		playbooks/libvirt_pcie_passthrough.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

$(KDEVOPS_GUESTFS_PROVISIONED):
	$(Q)if [[ "$(CONFIG_KDEVOPS_SSH_CONFIG_UPDATE)" == "y" ]]; then \
		$(TOPDIR)/scripts/update_ssh_config_guestfs.py; \
	fi
	$(Q)if [[ "$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK)" != "" ]]; then \
		ansible-playbook $(ANSIBLE_VERBOSE) -i \
			$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/$(KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK) ; \
	fi
	$(Q)touch $(KDEVOPS_GUESTFS_PROVISIONED)

bringup_guestfs: $(GUESTFS_BRINGUP_DEPS)
	$(Q)$(TOPDIR)/scripts/bringup_guestfs.sh
PHONY += bringup_guestfs

destroy_guestfs:
	$(Q)$(TOPDIR)/scripts/destroy_guestfs.sh
PHONY += destroy_guestfs

cleancache:
	$(Q)rm -f $(subst ",,$(CONFIG_KDEVOPS_STORAGE_POOL_PATH))/kdevops/guestfs/base_images/*
