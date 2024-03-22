# SPDX-License-Identifier: copyleft-next-0.3.1

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd='True'

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD_TIMEZONE))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd_timezone='True'
ANSIBLE_EXTRA_ARGS_DIRECT += devconfig_systemd_timesyncd_timezone='$(subst ",,$(CONFIG_DEVCONFIG_SYSTEMD_TIMESYNCD_TIMEZONE))'
endif

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD_NTP))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd_ntp='True'
endif

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD_NTP_GOOGLE))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd_ntp_google='True'
endif

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD_NTP_DEBIAN))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd_ntp_debian='True'
endif

ifeq (y,$(CONFIG_DEVCONFIG_ENABLE_SYSTEMD_TIMESYNCD_NTP_GOOGLE_DEBIAN))
ANSIBLE_EXTRA_ARGS += devconfig_enable_systemd_timesyncd_ntp_google_debian='True'
endif

timesyncd-client:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) -l baseline,dev \
		-f 30 -i hosts  \
		--extra-vars '{ kdevops_cli_install: True }' \
		--tags vars_simple,timesyncd \
		$(KDEVOPS_PLAYBOOKS_DIR)/devconfig.yml

timesyncd-server:
	@$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --connection=local \
		--inventory localhost, \
		$(KDEVOPS_PLAYBOOKS_DIR)/install_systemd_timesyncd.yml \
		-e 'ansible_python_interpreter=/usr/bin/python3'

timesyncd-status:
	@$(Q)timedatectl status


LOCALHOST_SETUP_WORK += timesyncd-server
KDEVOPS_BRING_UP_DEPS_EARLY += timesyncd-client

timesyncd-help:
	@echo "timesyncd-server    - Setup systemd-timesyncd on localhost"
	@echo "timesyncd-client    - Setup systemd-timesyncd on clients"
	@echo "timesyncd-status	   - Run timedatectl status"

HELP_TARGETS += timesyncd-help

endif
