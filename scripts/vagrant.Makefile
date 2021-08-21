# SPDX-License-Identifier: copyleft-next-0.3.1

KDEVOPS_BRING_UP_DEPS := bringup_vagrant
KDEVOPS_DESTROY_DEPS := destroy_vagrant

ifeq (y,$(CONFIG_HAVE_VAGRANT_BOX_URL))
VAGRANT_PRIVATE_BOX_DEPS := vagrant_private_box_install
else
VAGRANT_PRIVATE_BOX_DEPS :=
endif

EXTRA_VAR_INPUTS += extend-extra-args-vagrant

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
