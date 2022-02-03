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
include scripts/Kbuild.include

PROJECTVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
# Picks up the project version and appends it with any dirty information in
# case were have modified our tree.
PROJECTRELEASE = $(shell test -f $(CURDIR)/include/config/project.release && cat $(CURDIR)/include/config/project.release 2> /dev/null)

define filechk_project.release
	echo "$(PROJECTVERSION)$$($(CURDIR)/scripts/setlocalversion $(CURDIR))"
endef

include/config/project.release: $(CURDIR)/Makefile
	@$(call filechk,project.release)

export PROJECT PROJECTVERSION PROJECTRELEASE

scripts/kconfig/mconf:
	$(MAKE) -C scripts/kconfig/ .mconf-cfg
	$(MAKE) -C scripts/kconfig/ mconf

PHONY += menuconfig
menuconfig: scripts/kconfig/mconf include/config/project.release
	@$< Kconfig

scripts/kconfig/nconf:
	$(MAKE) -C scripts/kconfig/ .nconf-cfg
	$(MAKE) -C scripts/kconfig/ nconf

PHONY += nconfig
nconfig: scripts/kconfig/nconf include/config/project.release
	@$< Kconfig

scripts/kconfig/conf:
	$(MAKE) -C scripts/kconfig conf

# More are supported, however we only list the ones tested on this top
# level Makefile.
simple-targets := allnoconfig allyesconfig alldefconfig randconfig
PHONY += $(simple-targets)

$(simple-targets): scripts/kconfig/conf
	$< --$@ Kconfig

defconfig-%:: scripts/kconfig/conf
	@$< --defconfig=defconfigs/$(@:defconfig-%=%) Kconfig

.PHONY: $(PHONY)
