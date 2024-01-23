siw:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts playbooks/siw.yml

PHONY += siw
