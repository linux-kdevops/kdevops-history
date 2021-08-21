# SPDX-License-Identifier: copyleft-next-0.3.1

ifeq (y,$(CONFIG_KDEVOPS_TRY_REFRESH_REPOS))
ANSIBLE_EXTRA_ARGS += devconfig_try_refresh_repos=True
endif

ifeq (y,$(CONFIG_KDEVOPS_TRY_UPDATE_SYSTEMS))
ANSIBLE_EXTRA_ARGS += devconfig_try_upgrade=True
endif

ifeq (y,$(CONFIG_KDEVOPS_TRY_INSTALL_KDEV_TOOLS))
ANSIBLE_EXTRA_ARGS += devconfig_try_install_kdevtools=True
endif

ifeq (y,$(CONFIG_KDEVOPS_DEVCONFIG_ENABLE_CONSOLE))
ANSIBLE_EXTRA_ARGS += devconfig_enable_console=True
GRUB_TIMEOUT:=$(subst ",,$(CONFIG_KDEVOPS_GRUB_TIMEOUT))
ANSIBLE_EXTRA_ARGS += devconfig_grub_timeout=$(GRUB_TIMEOUT)
endif

EXTRA_VAR_INPUTS += extend-extra-args-devconfig

extend-extra-args-devconfig:
	@if [[ "$(CONFIG_KDEVOPS_ENABLE_DISTRO_EXTRA_ADDONS)" == "y" ]]; then \
		echo "devconfig_repos_addon: True" >> $(KDEVOPS_EXTRA_VARS) ;\
		cat $(KDEVOPS_EXTRA_ADDON_SOURCE) >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_DEVCONFIG_ENABLE_CONSOLE)" == "y" ]]; then \
		echo "devconfig_kernel_console: '$(CONFIG_KDEVOPS_DEVCONFIG_KERNEL_CONSOLE_SETTINGS)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_grub_console: '$(CONFIG_KDEVOPS_DEVCONFIG_GRUB_SERIAL_COMMAND)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
	@if [[ "$(CONFIG_KDEVOPS_DEVCONFIG_ENABLE_SYSTEMD_WATCHDOG)" == "y" ]]; then \
		echo "devconfig_systemd_watchdog_runtime_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_RUNTIME)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_systemd_watchdog_reboot_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_REBOOT)'" >> $(KDEVOPS_EXTRA_VARS) ;\
		echo "devconfig_systemd_watchdog_kexec_timeout: '$(CONFIG_KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_KEXEC)'" >> $(KDEVOPS_EXTRA_VARS) ;\
	fi
