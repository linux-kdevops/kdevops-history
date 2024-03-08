#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

[ -z "${TOPDIR}" ] && TOPDIR='.'
source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

export LIBVIRT_DEFAULT_URI=$CONFIG_LIBVIRT_URI

# On systems using system sesion, ensure that we start the default
# libvirt network.
if [[ "$CONFIG_LIBVIRT_URI_SYSTEM" == "y" ]]; then
	 sudo virsh net-list | grep -q default
	 if [[ $? -ne 0 ]]; then
		 sudo virsh net-start default
	 fi
fi

#
# We use the NVMe setting for virtio too (go figure), but IDE
# requires qcow2
#
IMG_FMT="qcow2"
if [ "${CONFIG_LIBVIRT_EXTRA_DRIVE_FORMAT_RAW}" = "y" ]; then
	IMG_FMT="raw"
fi
STORAGEDIR="${CONFIG_KDEVOPS_STORAGE_POOL_PATH}/kdevops/guestfs"
GUESTFSDIR="${TOPDIR}/guestfs"
OS_VERSION=${CONFIG_VIRT_BUILDER_OS_VERSION}
BASE_IMAGE_DIR="${STORAGEDIR}/base_images"
BASE_IMAGE="${BASE_IMAGE_DIR}/${OS_VERSION}.raw"
mkdir -p $STORAGEDIR
mkdir -p $BASE_IMAGE_DIR

cmdfile=$(mktemp)

if [ ! -f $BASE_IMAGE ]; then
	DO_UNREG=0
	if echo $OS_VERSION | grep -q '^rhel'; then
		if [ -n "$CONFIG_RHEL_ORG_ID" -a -n "$CONFIG_RHEL_ACTIVATION_KEY" ]; then
			DO_UNREG=1
			cat <<_EOT >>$cmdfile
run-command subscription-manager register --org=${CONFIG_RHEL_ORG_ID} --activationkey=${CONFIG_RHEL_ACTIVATION_KEY}
_EOT
		fi
	fi

	if [ -n "$CONFIG_KDEVOPS_CUSTOM_YUM_REPOFILE" ]; then
		cat <<_EOT >>$cmdfile
copy-in $CONFIG_KDEVOPS_CUSTOM_YUM_REPOFILE:/etc/yum.repos.d
_EOT
	fi

# basic pre-install customization
	cat <<_EOT >>$cmdfile
install sudo,qemu-guest-agent,python3,bash
run-command useradd -m kdevops -s /bin/bash
append-line /etc/sudoers.d/kdevops:kdevops   ALL=(ALL)       NOPASSWD: ALL
_EOT

	if [ $DO_UNREG -ne 0 ]; then
		cat <<_EOT >>$cmdfile
sm-unregister
_EOT
	fi

# Ugh, debian has to be told to bring up the network and regenerate ssh keys
# Hope we get that interface name right!
	if echo $OS_VERSION | grep -q '^debian'; then
		cat <<_EOT >>$cmdfile
append-line /etc/network/interfaces.d/enp1s0:auto enp1s0
append-line /etc/network/interfaces.d/enp1s0:allow-hotplug enp1s0
append-line /etc/network/interfaces.d/enp1s0:iface enp1s0 inet dhcp
firstboot-command dpkg-reconfigure openssh-server
_EOT
	fi

	echo "Generating new base image for ${OS_VERSION}"
	virt-builder ${OS_VERSION} --arch `uname -m` -o $BASE_IMAGE --size 20G --format raw --commands-from-file $cmdfile
fi

# FIXME: is there a yaml equivalent of jq?
grep -e '^  - name: ' ${TOPDIR}/guestfs/kdevops_nodes.yaml | sed 's/^  - name: //' | while read name
do
	#
	# If the guest is already defined, then just stop what we're doing
	# and plead to the developer to clean things up.
	#
	virsh domstate $name 1>/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "Domain $name is already defined."
		virsh start $name
		exit 0
	fi

	SSH_KEY_DIR="${GUESTFSDIR}/$name/ssh"
	SSH_KEY="${SSH_KEY_DIR}/id_ed25519"

	# Generate a new ssh key
	mkdir -p "$SSH_KEY_DIR"
	chmod 0700 "$SSH_KEY_DIR"
	rm -f $SSH_KEY $SSH_KEY.pub
	ssh-keygen -q -t ed25519 -f $SSH_KEY -N ""

	mkdir -p "$STORAGEDIR/$name"

	# Copy the base image and prep it
	ROOTIMG="$STORAGEDIR/$name/root.raw"
	cp --reflink=auto $BASE_IMAGE $ROOTIMG
	virt-sysprep -a $ROOTIMG --hostname $name --ssh-inject "kdevops:file:$SSH_KEY.pub"

	if [[ "$CONFIG_LIBVIRT_ENABLE_LARGEIO" == "y" ]]; then
		lbs_idx=1
		for i in $(seq 1 $(($CONFIG_QEMU_LARGEIO_MAX_POW_LIMIT+1))); do
			for x in $(seq 0 $CONFIG_QEMU_EXTRA_DRIVE_LARGEIO_NUM_DRIVES_PER_SPACE); do
				diskimg="$STORAGEDIR/$name/extra${lbs_idx}.${IMG_FMT}"
				rm -f $diskimg
				qemu-img create -f $IMG_FMT "$diskimg" 100G
				if [[ "$CONFIG_LIBVIRT_URI_SYSTEM" == "y" ]]; then
					chmod g+rw $diskimg
				fi
				let lbs_idx=$lbs_idx+1
			done
		done
	else
		# build some extra disks
		for i in $(seq 0 3); do
			diskimg="$STORAGEDIR/$name/extra${i}.${IMG_FMT}"
			rm -f $diskimg
			qemu-img create -f $IMG_FMT "$STORAGEDIR/$name/extra${i}.$IMG_FMT" 100G
			if [[ "$CONFIG_LIBVIRT_URI_SYSTEM" == "y" ]]; then
				chmod g+rw $STORAGEDIR/$name/extra${i}.$IMG_FMT
			fi
		done
	fi

	virsh define $GUESTFSDIR/$name/$name.xml
	XML_DEVICES_COUNT=$(find $GUESTFSDIR/$name/ -name pcie_passthrough_*.xml | wc -l)
	if [[ $XML_DEVICES_COUNT -gt 0 ]]; then
		for xml in $GUESTFSDIR/$name/pcie_passthrough_*.xml; do
			echo "Doing PCI-E passthrough for device $xml"
			virsh attach-device $name $xml --config
		done
	fi
	virsh start $name
	if [[ $? -ne 0 ]]; then
		echo "Failed to start $name"
		exit 1
	fi
done
