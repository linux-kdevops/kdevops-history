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

ifeq (y,$(CONFIG_GITR_NFS_SECTION_V42))
GITR_ARGS += gitr_nfs_section_v42=true
GITR_ENABLED_TEST_GROUPS += nfs-v42
endif
ifeq (y,$(CONFIG_GITR_NFS_SECTION_V41))
GITR_ARGS += gitr_nfs_section_v41=true
GITR_ENABLED_TEST_GROUPS += nfs-v41
endif
ifeq (y,$(CONFIG_GITR_NFS_SECTION_V40))
GITR_ARGS += gitr_nfs_section_v40=true
GITR_ENABLED_TEST_GROUPS += nfs-v40
endif
ifeq (y,$(CONFIG_GITR_NFS_SECTION_V3))
GITR_ARGS += gitr_nfs_section_v3=true
GITR_ENABLED_TEST_GROUPS += nfs-v3
endif
