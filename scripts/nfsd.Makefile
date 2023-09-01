NFSD_EXTRA_ARGS += nfsd_export_device_0='$(subst ",,$(CONFIG_NFSD_EXPORT_DEVICE_0))'
NFSD_EXTRA_ARGS += nfsd_export_device_1='$(subst ",,$(CONFIG_NFSD_EXPORT_DEVICE_1))'
NFSD_EXTRA_ARGS += nfsd_export_fstype='$(subst ",,$(CONFIG_NFSD_EXPORT_FSTYPE))'
NFSD_EXTRA_ARGS += nfsd_export_path='$(subst ",,$(CONFIG_NFSD_EXPORT_PATH))'
NFSD_EXTRA_ARGS += nfsd_export_options='$(subst ",,$(CONFIG_NFSD_EXPORT_OPTIONS))'
NFSD_EXTRA_ARGS += nfsd_threads=$(CONFIG_NFSD_THREADS)

ANSIBLE_EXTRA_ARGS += $(NFSD_EXTRA_ARGS)

nfsd:
	$(Q)ansible-playbook $(ANSIBLE_VERBOSE) --extra-vars=@./extra_vars.yaml \
		-f 30 -i hosts -l nfsd playbooks/nfsd.yml
