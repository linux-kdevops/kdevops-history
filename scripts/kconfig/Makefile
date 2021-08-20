CFLAGS=-Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer
LXDIALOG := lxdialog/checklist.o lxdialog/inputbox.o lxdialog/menubox.o lxdialog/textbox.o lxdialog/util.o lxdialog/yesno.o

default: mconf

zconf.tab.c: zconf.y
	@bison -ozconf.tab.c -t -l zconf.y
	@flex -ozconf.lex.c -L zconf.l

conf: conf.o zconf.tab.o
	$(CC) -o conf $^

mconf_CFLAGS :=  $(shell test -f $(CURDIR)/.mconf-cfg && . $(CURDIR)/.mconf-cfg && echo $$cflags) -DLOCALE
mconf_LDFLAGS := $(shell test -f $(CURDIR)/.mconf-cfg && . $(CURDIR)/.mconf-cfg && echo $$libs)
mconf: CFLAGS += ${mconf_CFLAGS}

nconf_CFLAGS :=  $(shell test -f $(CURDIR)/.nconf-cfg && . $(CURDIR)/.nconf-cfg && echo $$cflags) -DLOCALE
nconf_LDFLAGS := $(shell test -f $(CURDIR)/.nconf-cfg && . $(CURDIR)/.nconf-cfg && echo $$libs)
nconf: CFLAGS += ${nconf_CFLAGS}

include $(CURDIR)/../Kbuild.include
# check if necessary packages are available, and configure build flags
define filechk_conf_cfg
	$(CURDIR)/$<
endef

.%conf-cfg: %conf-cfg.sh
	$(call filechk,conf_cfg)

MCONF_DEPS := mconf.o zconf.tab.c $(LXDIALOG)
mconf: .mconf-cfg conf $(MCONF_DEPS)
	$(CC) -o mconf $(MCONF_DEPS) $(mconf_LDFLAGS)

NCONF_DEPS := nconf.o nconf.gui.o zconf.tab.c
nconf: .nconf-cfg conf $(NCONF_DEPS)
	$(CC) -o nconf $(NCONF_DEPS) $(nconf_LDFLAGS)

.PHONY: help
help:
	@echo "Configuration options:"
	@echo "menuconfig         - demos the menuconfig functionality"
	@echo "nconfig            - demos the nconfig functionality"
	@echo "allyesconfig       - enables all bells and whistles"
	@echo "allnoconfig        - disables all bells and whistles"
	@echo "randconfig         - random configuration"
	@echo "defconfig-*        - If you have files in the defconfig directory use default config from there"
	@echo ""
	@echo "Bringup"
	@echo "bringup            - Brings up target hosts"
	@echo "destroy            - Destroy all target hosts"
	@echo ""
	@echo "Linux git kernel development options"
	@echo "linux              - Git clones a linux git tree, build linux and reboots into it"
	@echo ""
	@echo "fstests options:"
	@echo "fstests                                 - Git clones fstests, builds and install it"
	@echo "fstests-baseline                        - Run fstests on baseline hosts and collect results"
	@echo "fstests-dev                             - Run fstests on dev hosts and collect results"
	@echo "fstests-baseline-results                - Only collect results for baseline hosts"
	@echo "fstests-dev-results                     - Only collect results for dev hosts"
	@echo "fstests-baseline-skip-kdevops-update    - Run fstests but skip updating kdevops"
	@echo "fstests-baseline-run-oscheck-only       - Only run oscheck"
	@echo "fstests-baseline-loop                   - Run fstests in a loop until a failure is found or steady state is reached"
	@echo "fstests-baseline-kernelci               - Run fstests kernel-ci loop"
	@echo ""
	@echo "blktests options:"
	@echo "blktests                                - Git clones blktests, builds and install it"
	@echo "blktests-baseline                        - Run blktests on baseline hosts and collect results"
	@echo "blktests-dev                             - Run fstests on dev hosts and collect results"
	@echo "blktests-baseline-results                - Only collect results for baseline hosts"
	@echo "blktests-dev-results                     - Only collect results for dev hosts"
	@echo "blktests-baseline-skip-kdevops-update    - Run fstests but skip updating kdevops"
	@echo "blktests-baseline-run-oscheck-only       - Only run oscheck"
	@echo "blktests-baseline-loop                   - Run blktests in a loop until a failure is found or steady state is reached"
	@echo "blktests-baseline-kernelci               - Run blktests kernel-ci loop"
	@echo ""
	@echo "reboot-limit options:"
	@echo "reboot-limit                             - Sets up the /data/reboot-limit directory"
	@echo "reboot-limit-baseline                    - Run the reboot-linit test on baseline hosts and collect results"
	@echo "reboot-limit-baseline-reset              - Reset the test boot counter for baseline"
	@echo "reboot-limit-dev                         - Run the reboot-limti test on dev hosts and collect results"
	@echo "reboot-limit-baseline-kernelci           - Run the reboot-limit kernel-ci loop"
	@echo ""
	@echo "kotd options:"
	@echo "kotd                  - Installs the latest kernel"
	@echo "kotd-baseline         - Installs the latest kernel on baseline hosts"
	@echo "kotd-dev              - Installs the latest kernel on dev hosts"

.PHONY: clean
clean:
	@rm -f conf mconf conf *.o lxdialog/*.o *.o zconf.tab.c .mconf-cfg
	@rm -rf *.o.d
