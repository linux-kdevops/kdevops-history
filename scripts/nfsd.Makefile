NFSD_EXTRA_ARGS += nfsd_export_device_prefix='$(subst ",,$(CONFIG_NFSD_EXPORT_DEVICE_PREFIX))'
NFSD_EXTRA_ARGS += nfsd_export_device_count='$(subst ",,$(CONFIG_NFSD_EXPORT_DEVICE_COUNT))'
NFSD_EXTRA_ARGS += nfsd_export_fstype='$(subst ",,$(CONFIG_NFSD_EXPORT_FSTYPE))'
NFSD_EXTRA_ARGS += nfsd_export_path='$(subst ",,$(CONFIG_NFSD_EXPORT_PATH))'
NFSD_EXTRA_ARGS += nfsd_export_options='$(subst ",,$(CONFIG_NFSD_EXPORT_OPTIONS))'
NFSD_EXTRA_ARGS += nfsd_threads=$(CONFIG_NFSD_THREADS)
NFSD_EXTRA_ARGS += nfsd_lease_time=$(CONFIG_NFSD_LEASE_TIME)

ANSIBLE_EXTRA_ARGS += $(NFSD_EXTRA_ARGS)

nfsd:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts -l nfsd playbooks/nfsd.yml
