# SPDX-License-Identifier: copyleft-next-0.3.1

GEN_NODES_EXTRA_ARGS += kdevops_nodes='$(KDEVOPS_NODES)'
GEN_NODES_EXTRA_ARGS += kdevops_nodes_template='$(KDEVOPS_NODES_TEMPLATE)'
GEN_NODES_EXTRA_ARGS += kdevops_nodes_template_full_path='$(TOPDIR_PATH)/$(KDEVOPS_NODES_TEMPLATE)'

GEN_NODES_EXTRA_ARGS += vagrant_box='$(subst ",,$(CONFIG_VAGRANT_BOX))'
GEN_NODES_EXTRA_ARGS += vagrant_box_version='$(subst ",,$(CONFIG_VAGRANT_BOX_VERSION))'
GEN_NODES_EXTRA_ARGS += vagrant_vcpus_count='$(subst ",,$(CONFIG_VAGRANT_VCPUS_COUNT))'
GEN_NODES_EXTRA_ARGS += vagrant_mem_mb='$(subst ",,$(CONFIG_VAGRANT_MEM_MB))'

GEN_NODES_EXTRA_ARGS += qemu_bin_path='$(subst ",,$(CONFIG_QEMU_BIN_PATH))'

GEN_NODES_EXTRA_ARGS += libvirt_uri='$(subst ",,$(CONFIG_LIBVIRT_URI))'
GEN_NODES_EXTRA_ARGS += libvirt_system_uri='$(subst ",,$(CONFIG_LIBVIRT_SYSTEM_URI))'

ifeq (y,$(CONFIG_LIBVIRT_HOST_PASSTHROUGH))
GEN_NODES_EXTRA_ARGS += libvirt_host_passthrough='True'
endif

ifeq (y,$(CONFIG_VAGRANT_LIBVIRT))
GEN_NODES_EXTRA_ARGS += libvirt_qemu_group='$(subst ",,$(CONFIG_LIBVIRT_QEMU_GROUP))'
endif

ifeq (y,$(CONFIG_LIBVIRT_SESSION))
GEN_NODES_EXTRA_ARGS += libvirt_session='True'
GEN_NODES_EXTRA_ARGS += libvirt_session_socket='$(subst ",,$(CONFIG_LIBVIRT_SESSION_SOCKET))'
GEN_NODES_EXTRA_ARGS += libvirt_session_management_network_device='$(subst ",,$(CONFIG_LIBVIRT_SESSION_MANAGEMENT_NETWORK_DEVICE))'
GEN_NODES_EXTRA_ARGS += libvirt_session_public_network_dev='$(subst ",,$(CONFIG_LIBVIRT_SESSION_PUBLIC_NETWORK_DEV))'
endif

ifeq (y,$(CONFIG_LIBVIRT_STORAGE_POOL_CREATE))
GEN_NODES_EXTRA_ARGS += libvirt_storage_pool_create='True'
GEN_NODES_EXTRA_ARGS += libvirt_storage_pool_name='$(subst ",,$(CONFIG_LIBVIRT_STORAGE_POOL_NAME))'
GEN_NODES_EXTRA_ARGS += libvirt_storage_pool_path='$(subst ",,$(CONFIG_LIBVIRT_STORAGE_POOL_PATH_CUSTOM))'
endif

ifeq (y,$(CONFIG_LIBVIRT_NVME_DRIVE_FORMAT_RAW))
GEN_NODES_EXTRA_ARGS += libvirt_nvme_drive_format='raw'
endif

ifeq (y,$(CONFIG_VAGRANT_ENABLE_ZNS))
GEN_NODES_EXTRA_ARGS += nvme_zone_enable='True'
GEN_NODES_EXTRA_ARGS += nvme_zone_drive_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_DRIVE_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_zasl='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_ZASL))'
GEN_NODES_EXTRA_ARGS += nvme_zone_capacity='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_CAPACITY))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_active='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_ACTIVE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_open='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_OPEN))'
GEN_NODES_EXTRA_ARGS += nvme_zone_physical_blocksize='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_PHYSICAL_BLOCKSIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_logical_blocksize='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_LOGICAL_BLOCKSIZE))'
endif

ifeq (y,$(CONFIG_LIBVIRT_MACHINE_TYPE_Q35))
GEN_NODES_EXTRA_ARGS += libvirt_override_machine_type='True'
GEN_NODES_EXTRA_ARGS += libvirt_machine_type='q35'

ifeq (y,$(CONFIG_QEMU_ENABLE_CXL))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl='True'
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_DEMO_TOPOLOGY_1))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_demo_topo1='True'
endif # QEMU_ENABLE_CXL_DEMO_TOPOLOGY_1
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_DEMO_TOPOLOGY_2))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_demo_topo2='True'
endif # QEMU_ENABLE_CXL_DEMO_TOPOLOGY_2
endif # CONFIG_QEMU_ENABLE_CXL

endif # CONFIG_LIBVIRT_MACHINE_TYPE_Q35

ANSIBLE_EXTRA_ARGS += $(GEN_NODES_EXTRA_ARGS)
