#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

# Convert the version string x.y.z to a canonical 5 or 6-digit form.
# Inspired by ld-version.sh on linux. This is the way.
get_canonical_version()
{
	IFS=.
	set -- $1

	# If the 2nd or 3rd field is missing, fill it with a zero.
	#
	# The 4th field, if present, is ignored.
	# This occurs in development snapshots as in 2.35.1.20201116
	echo $((10000 * $1 + 100 * ${2:-0} + ${3:-0}))
}

_vagrant_lacks_parallel()
{
	PARALLEL_MISSING="0.7.0"
	VAGRANT_LIBVIRT_VERSION="$(vagrant plugin list | sed -e 's|(| |g' | sed -e 's|,| |g' | awk '{print $2}')"

	OLD=$(get_canonical_version $PARALLEL_MISSING)
	CURRENT=$(get_canonical_version $VAGRANT_LIBVIRT_VERSION)
	if [[ "$CURRENT" -le "$OLD" ]]; then
		return 1
	fi
	return 0
}

vagrant_check_dups()
{
	NEW_POSSIBLE_INSTANCES=$(vagrant status --machine-readable | grep ",state," | awk -F"," '{print $2}')
	EXISTING_USER_INSTANCES=$(vagrant global-status | grep -A 200 -e "-----" | grep -v -e "----" | grep -B 200 "     "  | awk '{print $2}')
	for instance in $NEW_POSSIBLE_INSTANCES ; do
		INSTANCE_STATE=$(vagrant status --machine-readable | grep ",state," | awk -F",${instance}," '{print $2}' |awk -F"," '{print $2}')
		# We're dealing with a new local instance which is not created
		# yet. Now we check to see if globally this user doesn't have
		# an existing instance already created.
		if [[ "$INSTANCE_STATE" == "not_created" ]]; then
			INSTANCE_NEW="true"
			for old_instance in $EXISTING_USER_INSTANCES; do
				# An older instance already exists, complain
				if [[ "$instance" == "$old_instance" ]]; then
					INSTANCE_NEW="false"
					break
				fi
			done
			# At this point we're only dealing with not_created
			# instances *and* we know one does not exist in another
			# directory for this user.

			kdevops_pool_path="$CONFIG_KDEVOPS_STORAGE_POOL_PATH"
			# For libvirt we can do one more global sanity check
			if [[ "$CONFIG_LIBVIRT" == "y" ]]; then
				possible_image="${kdevops_pool_path}/vagrant_${instance}.img"
				if [[ -f $possible_image ]]; then
					echo "Image for instance $instance already exists ($possible_image), skippin bringup wipe of spare drives ..."
					continue
				fi
			fi

			# If we don't do this, old spare drives might be
			# left over and we'd be using them up again.
			spare_drive_instance_dir="${kdevops_pool_path}/kdevops/$instance"
			if [[ -d ${spare_drive_instance_dir} ]]; then
				echo "Wiping old instance spare drive directory ... $spare_drive_instance_dir"
				rm -rf ${kdevops_pool_path}/kdevops/$instance
			fi
		fi
	done
}

# This is just a workaround for fedora since we have an old vagrant-libvirt
# plugin that doesn't work with parallel
ARG=
if ! _vagrant_lacks_parallel; then
	ARG='--no-parallel'
fi
cd vagrant
if [[ "$CONFIG_VAGRANT_BOX_UPDATE_ON_BRINGUP" == "y" ]]; then
	if [[ ! -f $(basename "$KDEVOPS_VAGRANT_PROVISIONED") ]]; then
		vagrant box update
	fi
fi
if [[ "$CONFIG_VAGRANT_BOX_UPDATE_ON_BRINGUP" == "y" ]]; then
	vagrant validate
	if [[ $? -ne 0 ]]; then
		echo "kdevops: Failed to validate Vagrantfile, stopping here"
		exit 1
	fi
fi

vagrant_check_dups

vagrant up $ARG
