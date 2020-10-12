#!/bin/bash

REGISTER_SYSTEM="false"
REG_CODE=""

usage()
{
	echo "$0 - for updating your zypper list and registering a system if needed"
	echo "--register-system-code  <code> - registers this system using the given code"
	echo "--help                         - print help menu"
	echo ""
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--register-system-code)
			REGISTER_SYSTEM="true"
			REG_CODE="$2"
			shift
			shift
			;;
		--help)
			usage
			exit
			;;
		*)
			usage
			shift
			;;
		esac
	done
}

parse_args $@

if [ "$(id -u)" -ne 0 ]; then
    echo "Not running as root!"
    exit 1
fi

# If we are running SLE register the system
if [ "$(grep '^ID=' /etc/os-release | sed '/opensuse/d')" != "" ]; then
	# NAME is either SLES or SLED
	# the key is in a file key_sled or key_sles
	name=$(grep ^NAME= /etc/os-release|sed -e 's/NAME="//' -e 's/"//')

	# on SLED SUSEConnect tries to add the Nvidia repo with its own GPG key
	# => this causes a failure (as the key is unknown)
	# we therefore disable the Nvidia repo here, as it doesn't work with SLED 12
	# anyway and isn't really useful for a vagrant box
	if [ "$REGISTER_SYSTEM" == "true" ]; then
		set +e # (need to `set +e` as the SUSEConnect can fail)
		SUSEConnect --regcode $REG_CODE
		set -e
		if [ "${name}" = "SLED" ]; then
			nvidia_repo_id=$(zypper repos|grep -i nvidia|awk -F"|" '{ print $1 }')
			zypper --non-interactive modifyrepo -d ${nvidia_repo_id}
		fi
	fi
	zypper --non-interactive --gpg-auto-import-keys refresh
else
	zypper --non-interactive refresh
fi
