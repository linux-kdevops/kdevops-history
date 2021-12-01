#!/bin/bash
# custom virt-install script demo

ISO_URL="http://example.com/linux-release.iso"
REL="somedistro15sp3"
DATE_SHORT="$(date -I | sed -e 's/-//g')"
# Use DISK_BUS="scsi" if you are booting into a kernel which
# is old and does not have virtio
DISK_BUS="virtio"
MEM="2048"
CPUS="2"
QCOW2_SIZE="50g"

# No need to edit anything else below.
VIRT_NAME="${USER}-${REL}"
ISO_FILE="$(basename $ISO_URL)"
ISO_DIR="isos/$REL/"
ISO="$ISO_DIR/$ISO_FILE"

QCOW2_FILE="${REL}-${DATE_SHORT}"
QCOW2_DIR="images/$REL/"
QCOW2="$QCOW2_DIR/$QCOW2_FILE"

set_qcow2()
{
       if [ ! -f "$QCOW2" ]; then
               mkdir -p $QCOW2_DIR
               qemu-img create -f qcow2 $QCOW2 $QCOW2_SIZE
       fi
}

get_iso()
{
       if [ ! -f "$ISO" ]; then
               mkdir -p $ISO_DIR
               wget $ISO_URL -O $ISO
       fi
}

custom_virt_install()
{
       virt-install \
               --name $VIRT_NAME \
               --memory $MEM \
               --vcpus $CPUS \
               --network network=default \
               --nographics \
               --console pty,target_type=serial \
               --disk path=$QCOW2,device=disk,bus=$DISK_BUS,format=qcow2 \
               --location $ISO \
               --location $ISO \
               --extra-args 'console=ttyS0,115200n8 serial' \
               --os-variant $REL
}

set_qcow2
get_iso
custom_virt_install
