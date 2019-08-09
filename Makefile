.PHONY: all deps ansible_deps vagrant-deps

# Only needed for terraform
include globals.mk

# Only needed for terraform
DIRS=$(shell find ./* -maxdepth 0 -type d)

all: deps

vagrant-deps:
	@ansible-playbook -i hosts playbooks/kdevops_vagrant.yml

ansible_deps:
	@ansible-galaxy install --force -r requirements.yml

deps: ansible_deps vagrant-deps
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i deps; fi; done

# Only needed for terraform
clean:
	@for i in $(DIRS); do if [ -f $$i/Makefile ]; then $(MAKE) -C $$i clean; fi; done
