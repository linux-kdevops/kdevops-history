# SPDX-License-Identifier: GPL-2.0
#
# Simplified kconfig Makefile for subtree uses. This file is purposely
# maintained to be as simple as possible. The rest of the files in this
# directory are meant to match upstream.
#
# Part of the https://github.com/mcgrof/kconfig.git

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

.PHONY: clean
clean:
	@rm -f conf mconf conf *.o lxdialog/*.o *.o zconf.tab.c .mconf-cfg
	@rm -rf *.o.d
