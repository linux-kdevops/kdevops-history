NFSD_EXTRA_ARGS += nfsd_export_device='$(subst ",,$(CONFIG_NFSD_EXPORT_DEVICE))'
NFSD_EXTRA_ARGS += nfsd_export_fstype='$(subst ",,$(CONFIG_NFSD_EXPORT_FSTYPE))'
NFSD_EXTRA_ARGS += nfsd_export_path='$(subst ",,$(CONFIG_NFSD_EXPORT_PATH))'
NFSD_EXTRA_ARGS += nfsd_export_options='$(subst ",,$(CONFIG_NFSD_EXPORT_OPTIONS))'
NFSD_EXTRA_ARGS += nfsd_threads=$(CONFIG_NFSD_THREADS)

ANSIBLE_EXTRA_ARGS += $(NFSD_EXTRA_ARGS)

nfsd:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) \
		-f 30 -i hosts playbooks/nfsd.yml
