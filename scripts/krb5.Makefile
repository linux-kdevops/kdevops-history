ifeq (y,$(CONFIG_KDEVOPS_SETUP_KRB5))

KRB5_EXTRA_ARGS += krb5_realm='$(subst ",,$(CONFIG_KRB5_REALM))'
KRB5_EXTRA_ARGS += krb5_admin_pw='$(subst ",,$(CONFIG_KRB5_ADMIN_PW))'
KRB5_EXTRA_ARGS += kdevops_krb5_enable=True

ANSIBLE_EXTRA_ARGS += $(KRB5_EXTRA_ARGS)

kdc:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts -l kdc playbooks/kdc.yml

krb5:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts -l krb5 playbooks/krb5.yml

KDEVOPS_BRING_UP_DEPS += kdc
KDEVOPS_BRING_UP_LATE_DEPS += krb5

PHONY += kdc krb5

endif
