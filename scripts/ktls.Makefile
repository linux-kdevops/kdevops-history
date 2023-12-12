ktls:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts playbooks/ktls.yml

ktls-destroy:
	$(Q)rm -rf $(TOPDIR)/ca

PHONY += ktls ktls-destroy
