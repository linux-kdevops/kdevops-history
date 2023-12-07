# SPDX-License-Identifier: copyleft-next-0.3.1

VAGRANT_ARGS :=

KDEVOPS_NODES_TEMPLATE :=	$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/kdevops_nodes_split_start.j2.yaml
KDEVOPS_NODES :=		vagrant/kdevops_nodes.yaml

KDEVOPS_VAGRANT_TEMPLATE :=	$(KDEVOPS_NODES_ROLE_TEMPLATE_DIR)/Vagrantfile.j2
KDEVOPS_VAGRANT_GENERATED:=	vagrant/.Vagrantfile.generated
KDEVOPS_VAGRANT :=		vagrant/Vagrantfile
export KDEVOPS_VAGRANT_PROVISIONED :=	vagrant/.provisioned_once

KDEVOPS_MRPROPER +=		$(KDEVOPS_VAGRANT_GENERATED)
KDEVOPS_MRPROPER +=		$(KDEVOPS_VAGRANT)
KDEVOPS_MRPROPER +=		$(KDEVOPS_VAGRANT_PROVISIONED)

VAGRANT_ARGS += kdevops_vagrant_template_full_path='$(TOPDIR_PATH)/$(KDEVOPS_VAGRANT_TEMPLATE)'

VAGRANT_ARGS += kdevops_enable_vagrant=True
VAGRANT_ARGS += kdevops_vagrant='$(KDEVOPS_VAGRANT)'
VAGRANT_ARGS += kdevops_vagrant_generated='$(KDEVOPS_VAGRANT_GENERATED)'
VAGRANT_ARGS += kdevops_vagrant_template='$(KDEVOPS_VAGRANT_TEMPLATE)'

ifeq (y,$(CONFIG_HAVE_VAGRANT_BOX_URL))
VAGRANT_PRIVATE_BOX_DEPS := vagrant_private_box_install
else
VAGRANT_PRIVATE_BOX_DEPS :=
endif

VAGRANT_ARGS += kdevops_storage_pool_user='$(USER)'

ifeq (y,$(CONFIG_LIBVIRT))
VAGRANT_ARGS += libvirt_provider=True

QEMU_GROUP:=$(subst ",,$(CONFIG_LIBVIRT_QEMU_GROUP))
VAGRANT_ARGS += kdevops_storage_pool_group='$(QEMU_GROUP)'
VAGRANT_ARGS += storage_pool_group='$(QEMU_GROUP)'
endif

ifeq (y,$(CONFIG_VAGRANT_VIRTUALBOX))
VAGRANT_ARGS += virtualbox_provider=True
endif

STORAGE_POOL_PATH:=$(subst ",,$(CONFIG_KDEVOPS_STORAGE_POOL_PATH))
KDEVOPS_STORAGE_POOL_PATH:=$(STORAGE_POOL_PATH)/kdevops
VAGRANT_ARGS += storage_pool_path=$(STORAGE_POOL_PATH)
VAGRANT_ARGS += kdevops_storage_pool_path=$(KDEVOPS_STORAGE_POOL_PATH)

VAGRANT_9P_HOST_CLONE :=
ifeq (y,$(CONFIG_BOOTLINUX_9P))
VAGRANT_9P_HOST_CLONE := vagrant_9p_linux_clone
endif

LIBVIRT_PCIE_PASSTHROUGH :=
ifeq (y,$(CONFIG_KDEVOPS_LIBVIRT_PCIE_PASSTHROUGH))
LIBVIRT_PCIE_PASSTHROUGH := libvirt_pcie_passthrough_permissions
endif

ifneq ($(strip $(CONFIG_RHEL_ORG_ID)),)
ifneq ($(strip $(CONFIG_RHEL_ACTIVATION_KEY)),)
RHEL_ORG_ID:=$(subst ",,$(CONFIG_RHEL_ORG_ID))
RHEL_ACTIVATION_KEY:=$(subst ",,$(CONFIG_RHEL_ACTIVATION_KEY))
VAGRANT_ARGS += rhel_org_id="$(RHEL_ORG_ID)"
VAGRANT_ARGS += rhel_activation_key="$(RHEL_ACTIVATION_KEY)"
endif
endif

EXTRA_VAR_INPUTS += extend-extra-args-vagrant
ANSIBLE_EXTRA_ARGS += $(VAGRANT_ARGS)

VAGRANT_BRINGUP_DEPS :=
VAGRANT_BRINGUP_DEPS +=  $(VAGRANT_PRIVATE_BOX_DEPS)
VAGRANT_BRINGUP_DEPS +=  $(VAGRANT_9P_HOST_CLONE)
VAGRANT_BRINGUP_DEPS +=  $(LIBVIRT_PCIE_PASSTHROUGH)

KDEVOPS_BRING_UP_DEPS := bringup_vagrant
# Provisioning goes last
KDEVOPS_BRING_UP_DEPS += $(KDEVOPS_VAGRANT_PROVISIONED)

KDEVOPS_DESTROY_DEPS := destroy_vagrant

extend-extra-args-vagrant:
	@if [[ "$(CONFIG_HAVE_VAGRANT_BOX_URL)" == "y" ]]; then \
		echo "kdevops_install_vagrant_boxes: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "vagrant_boxes:" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "  - { name: '$(CONFIG_VAGRANT_BOX)', box_url: '$(CONFIG_VAGRANT_BOX_URL)' }" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi

vagrant_private_box_install:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/install_vagrant_boxes.yml

vagrant_9p_linux_clone:
	$(Q)make linux-clone

libvirt_pcie_passthrough_permissions:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		playbooks/libvirt_pcie_passthrough.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

$(KDEVOPS_VAGRANT_PROVISIONED):
	$(Q)if [[ "$(CONFIG_KDEVOPS_SSH_CONFIG_UPDATE)" == "y" ]]; then \
		ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
			--inventory localhost, \
			playbooks/update_ssh_config_vagrant.yml \
			-e 'ansible_python_interpreter=/usr/bin/python3' ;\
	fi
	$(Q)if [[ "$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK)" != "" ]]; then \
		ansible-playbook $(ANSIBLE_VERBOSE) -i \
			$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/$(KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK) ;\
	fi
	$(Q)touch $(KDEVOPS_VAGRANT_PROVISIONED)

bringup_vagrant: $(VAGRANT_BRINGUP_DEPS)
	$(Q)$(TOPDIR)/scripts/bringup_vagrant.sh
PHONY += bringup_vagrant

destroy_vagrant:
	$(Q)$(TOPDIR)/scripts/destroy_vagrant.sh
