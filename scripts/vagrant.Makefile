# SPDX-License-Identifier: copyleft-next-0.3.1

VAGRANT_ARGS :=

KDEVOPS_BRING_UP_DEPS := bringup_vagrant
KDEVOPS_DESTROY_DEPS := destroy_vagrant

ifeq (y,$(CONFIG_HAVE_VAGRANT_BOX_URL))
VAGRANT_PRIVATE_BOX_DEPS := vagrant_private_box_install
else
VAGRANT_PRIVATE_BOX_DEPS :=
endif

VAGRANT_ARGS += kdevops_storage_pool_user='$(USER)'

ifeq (y,$(CONFIG_VAGRANT_LIBVIRT))
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

EXTRA_VAR_INPUTS += extend-extra-args-vagrant
ANSIBLE_EXTRA_ARGS += $(VAGRANT_ARGS)

extend-extra-args-vagrant:
	@if [[ "$(CONFIG_HAVE_VAGRANT_BOX_URL)" == "y" ]]; then \
		echo "kdevops_install_vagrant_boxes: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "vagrant_boxes:" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "  - { name: '$(CONFIG_VAGRANT_BOX)', box_url: '$(CONFIG_VAGRANT_BOX_URL)' }" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi

vagrant_private_box_install:
	$(Q)ansible-playbook -i \
		$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/install_vagrant_boxes.yml

bringup_vagrant: $(VAGRANT_PRIVATE_BOX_DEPS)
	$(Q)$(TOPDIR)/scripts/bringup_vagrant.sh
	$(Q)if [[ "$(CONFIG_KDEVOPS_SSH_CONFIG_UPDATE)" == "y" ]]; then \
		ansible-playbook --connection=local \
			--inventory localhost, \
			playbooks/update_ssh_config_vagrant.yml \
			-e 'ansible_python_interpreter=/usr/bin/python3' ;\
	fi
	$(Q)if [[ "$(CONFIG_KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK)" != "" ]]; then \
		ansible-playbook -i \
			$(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/$(KDEVOPS_ANSIBLE_PROVISION_PLAYBOOK) ;\
	fi

destroy_vagrant:
	$(Q)$(TOPDIR)/scripts/destroy_vagrant.sh
