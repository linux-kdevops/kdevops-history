# SPDX-License-Identifier: copyleft-next-0.3.1

ifeq (y,$(CONFIG_HAVE_DISTRO_REQUIRES_CUSTOM_SSH_KEXALGORITHMS))
SSH_KEXALGORITHMS:=$(subst ",,$(CONFIG_KDEVOPS_CUSTOM_SSH_KEXALGORITHMS))
ANSIBLE_EXTRA_ARGS += use_kexalgorithms=True
ANSIBLE_EXTRA_ARGS += kexalgorithms=$(SSH_KEXALGORITHMS)
endif

ifeq (y,$(CONFIG_KDEVOPS_SSH_CONFIG_UPDATE))
SSH_CONFIG_FILE:=$(subst ",,$(CONFIG_KDEVOPS_SSH_CONFIG))
ANSIBLE_EXTRA_ARGS += sshconfig=$(CONFIG_KDEVOPS_SSH_CONFIG)
endif

KDEVOPS_HOSTS_PREFIX:=$(subst ",,$(CONFIG_KDEVOPS_HOSTS_PREFIX))
ANSIBLE_EXTRA_ARGS += kdevops_host_prefix=$(KDEVOPS_HOSTS_PREFIX)

PHONY += remove-ssh-key
remove-ssh-key:
	$(NQ) Removing key pair for $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PRIVKEY)
	$(Q)rm -f $(KDEVOPS_SSH_PUBKEY)

$(KDEVOPS_SSH_PRIVKEY): .config
	$(NQ) Generating new private key: $(KDEVOPS_SSH_PRIVKEY)
	$(NQ) Generating new public key: $(KDEVOPS_SSH_PUBKEY)
	$(Q)$(TOPDIR)/scripts/gen_ssh_key.sh
