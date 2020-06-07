KDEVOPS_PLAYBOOKS_DIR :=	playbooks
KDEVOPS_HOSTFILE :=		hosts

-include Makefile.kdevops

# disable built-in rules for this file
.SUFFIXES:

.DEFAULT: deps

deps: kdevops_install
	$(MAKE) -f Makefile.kdevops kdevops_deps
PHONY := deps

kdevops_install:
	@ansible-galaxy install --force -r requirements.yml
	@ansible-playbook -i $(KDEVOPS_HOSTFILE) $(KDEVOPS_PLAYBOOKS_DIR)/kdevops_install.yml
PHONY += kdevops_install

.PHONY: $(PHONY)
