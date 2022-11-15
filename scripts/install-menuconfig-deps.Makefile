# SPDX-License-Identifier: copyleft-next-0.3.1

menuconfig-deps:
	@$(Q)ansible-playbook --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/install-menuconfig-deps.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		-e 'kdevops_first_run=True'
PHONY += menuconfig-deps

menuconfig-deps-help-menu:
	@echo "menuconfig-deps:   - Install base kdevops dependencies to run make menuconfig"
	@echo ""

HELP_TARGETS += menuconfig-deps-help-menu

ifeq (y,$(CONFIG_KDEVOPS_FIRST_RUN))
LOCALHOST_SETUP_WORK += menuconfig-deps
endif # CONFIG_KDEVOPS_FIRST_RUN
