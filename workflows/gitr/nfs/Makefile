GITR_ARGS += gitr_fstype=nfs
GITR_ARGS += gitr_uses_no_devices='True'

ifeq (y,$(CONFIG_GITR_USE_KDEVOPS_NFSD))
GITR_ARGS += gitr_nfs_server_host='$(subst ",,$(CONFIG_KDEVOPS_HOSTS_PREFIX))-nfsd'
GITR_ARGS += gitr_nfs_server_export='gitr'
GITR_ARGS += gitr_nfs_use_kdevops_nfsd='True'
else # CONFIG_GITR_USE_KDEVOPS_NFSD
GITR_ARGS += gitr_nfs_server_host='$(subst ",,$(CONFIG_GITR_NFS_SERVER_HOSTNAME))'
GITR_ARGS += gitr_nfs_server_export='$(subst ",,$(CONFIG_GITR_NFS_SERVER_EXPORT))'
GITR_ARGS += gitr_nfs_use_kdevops_nfsd='False'
endif # CONFIG_GITR_USE_KDEVOPS_NFSD

GITR_ARGS += gitr_mount_opts='$(subst ",,$(CONFIG_GITR_NFS_MOUNT_OPTS))'
