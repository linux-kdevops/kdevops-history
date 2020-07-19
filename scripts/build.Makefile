# SPDX-License-Identifier: GPL-2.0
#
# Houses the targets which top level Makfiles can also define.
PHONY += clean
clean: $(clean-subdirs)
	$(MAKE) -C scripts/kconfig/ clean
	@rm -f *.o $(obj-y)

PHONY += mrproper
mrproper:
	@rm -rf $(CURDIR)/include/config/
	@rm -rf $(CURDIR)/include/generated/
	@rm -f .config

version-check: include/config/project.release
	@echo Version: $(PROJECTVERSION)
	@echo Release: $(PROJECTRELEASE)

PHONY += help
help:
	@$(MAKE) -s -C scripts/kconfig help
	@echo "Defaults configs:"					;\
	(cd defconfigs ; for f in $$(ls) ; do				\
		echo "defconfig-$$f"					;\
	done )
	@echo "Debugging"
	@echo "version-check      - demos version release functionality"
	@echo "clean              - cleans all output files"

.PHONY: $(PHONY)
