FSTESTS?="/var/lib/xfstests"
FSTESTS_CONFIGS?= $(FSTESTS)/configs
BASHRC?= $(HOME)/.bashrc
FSTYP?="xfs"

TRUNCATE_PATH="/media/truncated"

PROGS := gendisks.sh gen-expunge.sh oscheck.sh naggy-check.sh
SETUP_FILE := .oscheck-setup

HOSTNAME := $(shell hostname)
HOSTNAME_CONFIG := $(HOSTNAME).config
TARGET_CONFIG := $(FSTESTS_CONFIGS)/$(HOSTNAME_CONFIG)
EXAMPLE_CONFIG := fstests-configs/$(FSTYP).config
ID=$(shell id -u)

.PHONY: all install deps

include globals.mk

DIRS=$(shell find ./* -maxdepth 0 -type d)

all: $(PROGS)

deps:
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i deps; fi; done

install: $(PROGS)
	@if [ $(ID) != "0" ]; then \
		echo "Must run as root" ;\
		exit 1 ;\
	fi
	@mkdir -p $(FSTESTS)
	@mkdir -p $(TRUNCATE_PATH)
	@$(foreach var,$(PROGS), \
		if [ ! -f $(FSTESTS)/$(var) ]; then \
			echo SYMLINK $(var) on $(FSTESTS); \
			ln -sf $(shell readlink -f $(var)) $(FSTESTS); \
		fi; \
		)
	@if [ -f $(BASHRC) ]; then \
		if ! grep $(SETUP_FILE) $(BASHRC) 2>&1 > /dev/null ; then \
			echo "REFER $(SETUP_FILE) on $(BASHRC)" ;\
			cat .bashrc >> $(BASHRC) ;\
		fi \
	else \
		echo "INSTALL $(BASHRC)" ;\
		echo "#!/bin/bash" >> $(BASHRC) ;\
		cat .bashrc >> $(BASHRC) ;\
		chmod 755 $(BASHRC) ;\
	fi

	@echo INSTALL $(SETUP_FILE) $(HOME)
	@install $(SETUP_FILE) $(HOME)
	@cat $(HOME)/$(SETUP_FILE) | sed 's|export FSTYP=.*|export FSTYP="'$(FSTYP)'"|' | tee $(HOME)/$(SETUP_FILE) 2>&1 > /dev/null

	@mkdir -p $(FSTESTS_CONFIGS)
	@echo INSTALL $(HOSTNAME_CONFIG)  $(FSTESTS_CONFIGS)
	@if [ ! -f $(EXAMPLE_CONFIG) ]; then \
		echo "Unsupported filesystem: $(FSTYP)" ;\
		echo "Consider adding an example fstests config in $(EXAMPLE_CONFIG) and submit to oscheck upstream" ;\
		exit 1 ;\
	fi
	@install $(EXAMPLE_CONFIG) $(TARGET_CONFIG)

	@export TEST_VAR=$(shell grep ^TEST_DEV $(TARGET_CONFIG)) && echo "export $$TEST_VAR" >> $(HOME)/$(SETUP_FILE)

	@echo After this, consider running the following as root to check for fstests build dependencies:
	@echo	$(FSTESTS)/oscheck.sh --check-deps
	@echo
	@echo To try to get oscheck to install fstests build dependencies run the following a few times:
	@echo	$(FSTESTS)/oscheck.sh --install-deps

clean:
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i clean; fi; done
