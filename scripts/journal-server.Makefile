# SPDX-License-Identifier: copyleft-next-0.3.1

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE))

JOURNAL_REMOTE:=$(subst ",,$(CONFIG_DEVCONFIG_SYSTEMD_JOURNAL_REMOTE_URL))
ANSIBLE_EXTRA_ARGS += devconfig_systemd_journal_remote_url=$(JOURNAL_REMOTE)
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_journal_remote='True'

journal-client:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--extra-vars '{ kdevops_cli_install: True }' \
		--tags vars_simple,journal \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-server:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/install_systemd_journal_remote.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

journal-restart:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal-upload-restart \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-status:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal-status \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

journal-ls:
	@$(Q)./workflows/kdevops/scripts/jounal-ls.sh /var/log/journal/remote/

journal-ln:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--tags vars_extra,journal_ln \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

KDEVOPS_BRING_UP_DEPS += journal-server

journal-help:
	@echo "journal-server	   - Setup systemd-journal-remote on localhost"
	@echo "journal-client	   - Setup systemd-journal-upload on clients"
	@echo "journal-restart	   - Restart client upload service"
	@echo "journal-status	   - Ensure systemd-journal-remote works"
	@echo "journal-ls          - List journals available and sizes"
	@echo "journal-ln          - Add symlinks with hostnames"

HELP_TARGETS += journal-help

endif
