ifeq (y,$(CONFIG_KDEVOPS_SETUP_SIW))

siw:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts playbooks/siw.yml

KDEVOPS_BRING_UP_DEPS += siw

PHONY += siw

endif
