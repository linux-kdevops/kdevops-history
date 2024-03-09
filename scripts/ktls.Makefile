ifeq (y,$(CONFIG_KDEVOPS_SETUP_KTLS))

ktls:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts playbooks/ktls.yml

ktls-destroy:
	$(Q)rm -rf $(TOPDIR)/ca

KDEVOPS_BRING_UP_DEPS += ktls
KDEVOPS_DESTROY_DEPS += ktls-destroy

PHONY += ktls ktls-destroy

endif
