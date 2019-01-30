FSTESTS?="/var/lib/xfstests"
FSTESTS_CONFIGS?= $(FSTESTS)/configs
BASHRC?= $(HOME)/.bashrc

TRUNCATE_PATH="/media/truncated"

PROGS := gendisks.sh gen-expunge.sh oscheck.sh naggy-check.sh
SETUP_FILE := .oscheck-setup

HOSTNAME := $(shell hostname)
HOSTNAME_CONFIG := $(HOSTNAME).config
TARGET_CONFIG := $(FSTESTS_CONFIGS)/$(HOSTNAME_CONFIG)
EXAMPLE_CONFIG := example.config
ID=$(shell id -u)

.PHONY: all install

all: $(PROGS)

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
	@if [ ! -f $(HOME)/$(SETUP_FILE) ]; then \
		echo INSTALL $(SETUP_FILE) $(HOME) ;\
		install $(SETUP_FILE) $(HOME) ;\
	fi
	@mkdir -p $(FSTESTS_CONFIGS)
	@if [ ! -f $(TARGET_CONFIG) ]; then \
		echo INSTALL $(HOSTNAME_CONFIG)  $(FSTESTS_CONFIGS) ;\
		install $(EXAMPLE_CONFIG) $(TARGET_CONFIG) ;\
	fi
	@echo After this, consider running the following as root to check for fstests build dependencies:
	@echo	$(FSTESTS)/oscheck.sh --check-deps
	@echo
	@echo To try to get oscheck to install fstests build dependencies run the following a few times:
	@echo	$(FSTESTS)/oscheck.sh --install-deps
