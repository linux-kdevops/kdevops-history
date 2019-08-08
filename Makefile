BASHRC?= $(HOME)/.bashrc

KDEVOPS_PROJECT?="demo"
SETUP_FILE := .$(KDEVOPS_PROJECT)-kdevops-setup
HOSTNAME := $(shell hostname)
ID=$(shell id -u)

.PHONY: all install deps ansible_deps vagrant-deps

include globals.mk

DIRS=$(shell find ./* -maxdepth 0 -type d)

all: deps

vagrant-deps:
	@ansible-playbook -i hosts playbooks/kdevops_vagrant.yml

ansible_deps:
	@ansible-galaxy install --force -r requirements.yml

deps: ansible_deps vagrant-deps
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i deps; fi; done

install:
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

clean:
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i clean; fi; done
