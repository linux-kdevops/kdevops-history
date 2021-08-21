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
