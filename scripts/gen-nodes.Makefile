# SPDX-License-Identifier: copyleft-next-0.3.1

GEN_NODES_EXTRA_ARGS += kdevops_nodes='$(KDEVOPS_NODES)'
GEN_NODES_EXTRA_ARGS += kdevops_nodes_template='$(KDEVOPS_NODES_TEMPLATE)'
GEN_NODES_EXTRA_ARGS += kdevops_nodes_template_full_path='$(TOPDIR_PATH)/$(KDEVOPS_NODES_TEMPLATE)'

GEN_NODES_EXTRA_ARGS += vagrant_box='$(subst ",,$(CONFIG_VAGRANT_BOX))'
GEN_NODES_EXTRA_ARGS += vagrant_box_version='$(subst ",,$(CONFIG_VAGRANT_BOX_VERSION))'
GEN_NODES_EXTRA_ARGS += libvirt_vcpus_count='$(subst ",,$(CONFIG_LIBVIRT_VCPUS_COUNT))'
GEN_NODES_EXTRA_ARGS += libvirt_mem_mb='$(subst ",,$(CONFIG_LIBVIRT_MEM_MB))'

ifeq (y,$(CONFIG_QEMU_BUILD))

  ifeq (y,$(CONFIG_TARGET_ARCH_X86_64))
  GEN_NODES_EXTRA_ARGS += qemu_bin_path='$(subst ",,$(CONFIG_QEMU_INSTALL_DIR_LIBVIRT))/qemu-system-x86_64'
  endif

  ifeq (y,$(CONFIG_TARGET_ARCH_PPC64LE))
  GEN_NODES_EXTRA_ARGS += qemu_bin_path='$(subst ",,$(CONFIG_QEMU_INSTALL_DIR_LIBVIRT))/qemu-system-ppc64'
  endif

else
GEN_NODES_EXTRA_ARGS += qemu_bin_path='$(subst ",,$(CONFIG_QEMU_BIN_PATH))'
endif


GEN_NODES_EXTRA_ARGS += libvirt_uri='$(subst ",,$(CONFIG_LIBVIRT_URI))'
GEN_NODES_EXTRA_ARGS += libvirt_system_uri='$(subst ",,$(CONFIG_LIBVIRT_SYSTEM_URI))'

ifeq (y,$(CONFIG_LIBVIRT_HOST_PASSTHROUGH))
GEN_NODES_EXTRA_ARGS += libvirt_host_passthrough='True'
endif

ifeq (y,$(CONFIG_LIBVIRT))
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
GEN_NODES_EXTRA_ARGS += libvirt_storage_pool_path='$(subst ",,$(CONFIG_KDEVOPS_STORAGE_POOL_PATH))'
endif

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_DRIVE_IDE))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_drive_nvme='False'
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_drive_ide='True'
endif

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_DRIVE_VIRTIO))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_drive_nvme='False'
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_drive_virtio='True'
endif

GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_aio_mode='$(subst ",,$(CONFIG_LIBVIRT_AIO_MODE))'
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_aio_cache_mode='$(subst ",,$(CONFIG_LIBVIRT_AIO_CACHE_MODE))'

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_DRIVE_NVME))
ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_512))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='512'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_1K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='1024'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_2K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='2048'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_4K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='4096'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_8K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='8192'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_16K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='16384'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_32K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='32768'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_64K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='65536'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_128K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='131072'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_256K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='262144'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_512K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='524288'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_1M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='1048576'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_NVME_LOGICAL_BLOCK_SIZE_2M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='2097152'
else
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_nvme_logical_block_size='512'
endif
endif

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_DRIVE_VIRTIO))
ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_512))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='512'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_1K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='1024'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_2K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='2048'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_4K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='4096'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_8K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='8192'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_16K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='16384'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_32K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='32768'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_64K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='65536'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_128K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='131072'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_256K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='262144'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_512K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='524288'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_1M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='1048576'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_PHYSICAL_BLOCK_SIZE_2M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='2097152'
else
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_physical_block_size='512'
endif

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_512))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='512'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_1K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='1024'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_2K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='2048'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_4K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='4096'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_8K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='8192'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_16K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='16384'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_32K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='32768'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_64K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='65536'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_128K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='131072'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_256K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='262144'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_512K))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='524288'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_1M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='1048576'
else ifeq (y,$(CONFIG_LIBVIRT_EXTRA_STORAGE_VIRTIO_LOGICAL_BLOCK_SIZE_2M))
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='2097152'
else
GEN_NODES_EXTRA_ARGS += libvirt_extra_storage_virtio_logical_block_size='512'
endif
endif

ifeq (y,$(CONFIG_LIBVIRT_EXTRA_DRIVE_FORMAT_RAW))
GEN_NODES_EXTRA_ARGS += libvirt_extra_drive_format='raw'
endif
ifeq (y,$(CONFIG_VAGRANT_VIRTUALBOX))
GEN_NODES_EXTRA_ARGS += libvirt_extra_drive_format='$(subst ",,$(CONFIG_VIRTUALBOX_EXTRA_DRIVE_FORMAT))'
endif

ifeq (y,$(CONFIG_LIBVIRT_ENABLE_ZNS))
GEN_NODES_EXTRA_ARGS += nvme_zone_enable='True'
GEN_NODES_EXTRA_ARGS += nvme_zone_drive_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_DRIVE_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_zasl='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_ZASL))'
GEN_NODES_EXTRA_ARGS += nvme_zone_capacity='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_CAPACITY))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_active='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_ACTIVE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_open='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_OPEN))'
GEN_NODES_EXTRA_ARGS += nvme_zone_physical_block_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_PHYSICAL_BLOCK_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_logical_block_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_LOGICAL_BLOCK_SIZE))'
endif

ifeq (y,$(CONFIG_LIBVIRT_ENABLE_LARGEIO))
GEN_NODES_EXTRA_ARGS += libvirt_largeio_enable='True'
ifeq (y,$(CONFIG_QEMU_EXTRA_DRIVE_LARGEIO_COMPAT))
GEN_NODES_EXTRA_ARGS += libvirt_largeio_logical_compat='True'
endif
GEN_NODES_EXTRA_ARGS += libvirt_largeio_drives_per_space='$(subst ",,$(CONFIG_QEMU_EXTRA_DRIVE_LARGEIO_NUM_DRIVES_PER_SPACE))'
GEN_NODES_EXTRA_ARGS += libvirt_largeio_base_size='$(subst ",,$(CONFIG_QEMU_LARGEIO_DRIVE_BASE_SIZE))'
GEN_NODES_EXTRA_ARGS += libvirt_largeio_logical_compat_size='$(subst ",,$(CONFIG_QEMU_LARGEIO_COMPAT_SIZE))'
GEN_NODES_EXTRA_ARGS += libvirt_largeio_pow_limit='$(subst ",,$(CONFIG_QEMU_LARGEIO_MAX_POW_LIMIT))'
endif

ifeq (y,$(CONFIG_LIBVIRT_MACHINE_TYPE_Q35))
GEN_NODES_EXTRA_ARGS += libvirt_override_machine_type='True'
GEN_NODES_EXTRA_ARGS += libvirt_machine_type='q35'

ifeq (y,$(CONFIG_QEMU_ENABLE_CXL))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl='True'
ifeq (y,$(CONFIG_QEMU_START_QMP_ON_TCP_SOCKET))
GEN_NODES_EXTRA_ARGS += libvirt_enable_qmp='True'
GEN_NODES_EXTRA_ARGS += libvirt_qemu_qmp_string='$(subst ",,$(CONFIG_QEMU_QMP_COMMAND_LINE_STRING))'
ifeq (y,$(CONFIG_QEMU_QMP_WAIT_ON))
GEN_NODES_EXTRA_ARGS += libvirt_qemu_qmp_wait='True'
else
GEN_NODES_EXTRA_ARGS += libvirt_qemu_qmp_wait='False'
endif # CONFIG_QEMU_QMP_WAIT_ON
endif # CONFIG_QEMU_START_QMP_ON_TCP_SOCKET
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_DEMO_TOPOLOGY_1))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_demo_topo1='True'
endif # QEMU_ENABLE_CXL_DEMO_TOPOLOGY_1
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_DEMO_TOPOLOGY_2))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_demo_topo2='True'
endif # QEMU_ENABLE_CXL_DEMO_TOPOLOGY_2
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_SWITCH_TOPOLOGY_1))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_switch_topo1='True'
endif # QEMU_ENABLE_CXL_SWITCH_TOPOLOGY_1
ifeq (y,$(CONFIG_QEMU_ENABLE_CXL_DEMO_DCD_TOPOLOGY_1))
GEN_NODES_EXTRA_ARGS += libvirt_enable_cxl_dcd_topo1='True'
endif # QEMU_ENABLE_CXL_DEMO_DCD_TOPOLOGY_1
endif # CONFIG_QEMU_ENABLE_CXL

endif # CONFIG_LIBVIRT_MACHINE_TYPE_Q35

ANSIBLE_EXTRA_ARGS += $(GEN_NODES_EXTRA_ARGS)
