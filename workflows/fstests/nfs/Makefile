FSTESTS_ARGS += fstests_nfs_enable='True'
FSTESTS_NFS_SERVER_HOST:=$(subst ",,$(CONFIG_FSTESTS_NFS_SERVER_HOST))
ifeq (y,$(CONFIG_FSTESTS_USE_KDEVOPS_NFSD))
FSTESTS_NFS_SERVER_HOST:=$(subst ",,$(CONFIG_KDEVOPS_HOSTS_PREFIX))-nfsd
FSTESTS_ARGS += fstests_nfs_use_kdevops_nfsd='True'
endif # CONFIG_FSTESTS_USE_KDEVOPS_NFSD
FSTESTS_ARGS += fstests_nfs_server_host='$(FSTESTS_NFS_SERVER_HOST)'

ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_DEFAULT))
FSTESTS_ARGS += fstests_nfs_section_default=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_RDMA))
FSTESTS_ARGS += fstests_nfs_section_rdma=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_TLS))
FSTESTS_ARGS += fstests_nfs_section_tls=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_V42))
FSTESTS_ARGS += fstests_nfs_section_v42=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_V41))
FSTESTS_ARGS += fstests_nfs_section_v41=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_V40))
FSTESTS_ARGS += fstests_nfs_section_v40=True
endif
ifeq (y,$(CONFIG_FSTESTS_NFS_SECTION_V3))
FSTESTS_ARGS += fstests_nfs_section_v3=True
endif

ifdef CONFIG_FSTESTS_NFS_AUTH_FLAVOR
FSTESTS_ARGS += fstests_nfs_auth_flavor='$(subst ",,$(CONFIG_FSTESTS_NFS_AUTH_FLAVOR))'
endif
