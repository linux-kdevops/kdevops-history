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

ifeq (y,$(CONFIG_LIBVIRT_SESSION))
GEN_NODES_EXTRA_ARGS += libvirt_session='True'
GEN_NODES_EXTRA_ARGS += libvirt_session_socket='$(subst ",,$(CONFIG_LIBVIRT_SESSION_SOCKET))'
GEN_NODES_EXTRA_ARGS += libvirt_session_management_network_device='$(subst ",,$(CONFIG_LIBVIRT_SESSION_MANAGEMENT_NETWORK_DEVICE))'
GEN_NODES_EXTRA_ARGS += libvirt_session_public_network_dev='$(subst ",,$(CONFIG_LIBVIRT_SESSION_PUBLIC_NETWORK_DEV))'
endif

ifeq (y,$(CONFIG_VAGRANT_ENABLE_ZNS))
GEN_NODES_EXTRA_ARGS += nvme_zone_enable='True'
GEN_NODES_EXTRA_ARGS += nvme_zone_drive_size='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_DRIVE_SIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_zasl='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_ZASL))'
GEN_NODES_EXTRA_ARGS += nvme_zone_capacity='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_CAPACITY))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_active='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_ACTIVE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_max_open='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_MAX_OPEN))'
GEN_NODES_EXTRA_ARGS += nvme_zone_physical_blocksize='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_PHYSICAL_BLOCKSIZE))'
GEN_NODES_EXTRA_ARGS += nvme_zone_logical_blocksize='$(subst ",,$(CONFIG_QEMU_NVME_ZONE_LOGICAL_BLOCKSIZE))'
endif

ANSIBLE_EXTRA_ARGS += $(GEN_NODES_EXTRA_ARGS)
