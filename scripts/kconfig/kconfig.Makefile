# SPDX-License-Identifier: GPL-2.0
#
# Generic Makefile for userspace kconfig integration / generic simple
# obj-y build helpers.

# Bring in all the options selected
#
# Using optional include with -include will still try to process our .config
# target, and we don't want that unless the user manually specified that or
# its part of a dependency chain listing. To do this we have to avoid doing
# the optional include unless it actually exists, so we re-invent an optional
# include which doesn't get used unless actually used as a target.
ifeq (,$(wildcard $(CURDIR)/.config))
else
include .config
endif

# Kconfig filechk magic helper
include $(KCONFIG_DIR)/Kbuild.include

PROJECTVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
# Picks up the project version and appends it with any dirty information in
# case were have modified our tree.
PROJECTRELEASE = $(shell test -f $(CURDIR)/include/config/project.release && cat $(CURDIR)/include/config/project.release 2> /dev/null)

define filechk_project.release
	echo "$(PROJECTVERSION)$$($(KCONFIG_DIR)/setlocalversion $(CURDIR))"
endef

include/config/project.release: $(CURDIR)/Makefile
	@$(call filechk,project.release)

export PROJECT PROJECTVERSION PROJECTRELEASE

$(KCONFIG_DIR)/mconf:
	$(MAKE) -C $(KCONFIG_DIR)/ .mconf-cfg
	$(MAKE) -C $(KCONFIG_DIR)/ mconf

PHONY += menuconfig
menuconfig: $(KCONFIG_DIR)/mconf include/config/project.release
	@$< Kconfig

$(KCONFIG_DIR)/nconf:
	$(MAKE) -C $(KCONFIG_DIR)/ .nconf-cfg
	$(MAKE) -C $(KCONFIG_DIR)/ nconf

PHONY += nconfig
nconfig: $(KCONFIG_DIR)/nconf include/config/project.release
	@$< Kconfig

$(KCONFIG_DIR)/conf:
	$(MAKE) -C $(KCONFIG_DIR) conf

# More are supported, however we only list the ones tested on this top
# level Makefile.
simple-targets := allnoconfig allyesconfig alldefconfig randconfig
PHONY += $(simple-targets)

$(simple-targets): $(KCONFIG_DIR)/conf
	$< --$@ Kconfig

defconfig-%:: $(KCONFIG_DIR)/conf
	@$< --defconfig=defconfigs/$(@:defconfig-%=%) Kconfig

.PHONY: $(PHONY)
