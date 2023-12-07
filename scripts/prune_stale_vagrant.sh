#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

source .config
source scripts/lib.sh

SUDO_REQ="sudo"
EVALUATE="false"
THIS_SCRIPT=$0

run_prune_path()
{
	EVAL_ARGS=""
	if [[ "$1" == "true" ]]; then
		EVAL_ARGS="--evaluate"
	fi
	POOLS=$($SUDO_REQ virsh pool-list | grep -A 2000 -e "---" | grep -v -e "---" | awk '{print $1}')
	for p in $POOLS; do
		POOL_PATH=$($SUDO_REQ virsh pool-dumpxml $p | grep path | sed -e 's|<path>||' | sed -e 's|</path>||' | awk '{print $1}')
		echo "Evaluating pool $p with path $POOL_PATH ..."
		$THIS_SCRIPT $EVAL_ARGS $POOL_PATH
		if [[ $? -ne 0 ]]; then
			echo "Inspect pool $p there is something odd with it or its empty and unused"
		fi
	done
}

if [[ "$CONFIG_LIBVIRT_URI_SESSION" == "y" ]]; then
	SUDO_REQ=""
fi

if [[ "$CONFIG_LIBVIRT" != "y" ]]; then
	echo "Only libvirt is supported at this time for this prune"
	exit 1
fi

if [[ $# -eq 0 ]]; then
	KDEVOPS_POOL_PATH="$CONFIG_KDEVOPS_STORAGE_POOL_PATH"
elif [[ $# -eq 1 ]]; then
	if [[ "$1" == "--help" ]]; then
		echo "Usage: $0"
		echo "          --evaluate                         -- evaluates how much savings you could on your configured pool"
		echo "          --evaluate  <path-to-libvirt-pool> -- evaluates how much savings you could on a specific pool path"
		echo "          --prune-eval-pools                 -- evaluates how much savings you could save if we tried to prune all kdevops pools"
		echo "          --prune-pools                      -- prunes all pools found for kdevops"
		exit
	elif [[ "$1" == "--prune-pools" ]]; then
		echo unsupported
		exit 1
		run_prune_path false
		exit
	elif [[ "$1" == "--prune-eval-pools" ]]; then
		run_prune_path true
		exit
	else
		KDEVOPS_POOL_PATH="$1"
	fi
elif [[ $# -eq 2 ]]; then
	if [[ "$1" == "--evaluate" ]]; then
		EVALUATE="true"
		KDEVOPS_POOL_PATH="$2"
	else
		echo "Usage: $0 --evaluate | $0 | $0 <path-to-libvirt-pool>"
		exit
	fi
else
	echo "Usage: $0 --evaluate | $0 | $0 <path-to-libvirt-pool>"
	exit
fi

if [[ ! -d $KDEVOPS_POOL_PATH ]]; then
	echo "$KDEVOPS_POOL_PATH does not exist, no need to prune, maybe destroy and undefine this pool"
	echo "Consider running the following if this is a stale pool:"
	echo "$SUDO_REQ virsh pool-destroy <pool-name>"
	echo "$SUDO_REQ virsh pool-undefine <pool-name>"
	exit 1
fi

HOMES=$(cat /etc/passwd| awk -F":" '{print $6}')
for i in $HOMES; do
	if [[ "$KDEVOPS_POOL_PATH" == "$i" || "$KDEVOPS_POOL_PATH" == "$i/" ]]; then
		echo "Skipping odd pool on a home directory $i"
		exit 1
	fi
done

EXISTING_USAGE=$(du -hs $KDEVOPS_POOL_PATH)
EXISTING_USAGE_BYTES=$(du -s --block-size=1 $KDEVOPS_POOL_PATH | awk '{print $1}')

echo -e "Existing disk usage:\n$EXISTING_USAGE"

ALL_LIBVIRT_INSTANCES=$($SUDO_REQ virsh list --all --title | grep -A 200 -e "----" | grep -v -e "---" | awk '{print $2}')

BYTES_COULD_SAVE=0

# Scan the libvirt images with a vagrant prefix images not registered somehow
# to libvirt. This would be odd. We ignore libvirt images not related to
# vagrant.
for i in ${KDEVOPS_POOL_PATH}/vagrant_*.img; do
	EXISTS="n"
	IMAGE_INSTANCE=$(basename ${i%*.img})
	for INSTANCE in $ALL_LIBVIRT_INSTANCES; do
		if [[ "$INSTANCE" == "$IMAGE_INSTANCE" ]]; then
			EXISTS="y"
		fi
	done
	if [[ "$EXISTS" == "n" ]]; then
		echo "Instance $IMAGE_INSTANCE does not exist and is therefore stale"
		if [[ "$EVALUATE" == "true" ]]; then
			BYTES=$(du -s --block-size=1 $i | awk '{print $1}')
			let BYTES_COULD_SAVE=$BYTES_COULD_SAVE+BYTES
		else
			rm -rf $i
		fi
	fi
done

# Now scan only the spare kdevops drives. Since we're only looking
# at the kdevops directory we are ignoring non-kdevops instances
# data.
for i in ${KDEVOPS_POOL_PATH}/kdevops/*; do
	EXISTS="n"
	if [[ ! -d $i ]]; then
		continue
	fi
	DIR=$(basename $i)
	for INSTANCE in $ALL_LIBVIRT_INSTANCES; do
		if [[ "vagrant_${DIR}" == "$INSTANCE" ]]; then
			EXISTS="y"
		fi
	done
	if [[ "$EXISTS" == "n" ]]; then
		echo "Spare kdevops drive exists without any instance: $DIR"
		if [[ "$EVALUATE" == "true" ]]; then
			BYTES=$(du -s --block-size=1 $i | awk '{print $1}')
			let BYTES_COULD_SAVE=$BYTES_COULD_SAVE+BYTES
		else
			rm -rf $i
		fi
	fi
done


if [[ "$EVALUATE" == "true" ]]; then
	if [[ "$BYTES_COULD_SAVE" == "0" ]]; then
		echo "Nothing to prune on $KDEVOPS_POOL_PATH"
	else
		echo "You could save $BYTES_COULD_SAVE bytes ( $((BYTES_COULD_SAVE/1024/1024)) MiB or $((BYTES_COULD_SAVE/1024/1024/1024)) GiB $((BYTES_COULD_SAVE/1024/1024/1024/1024)) TiB)"
	fi
else
	AFTER_USAGE_BYTES=$(du -s --block-size=1 $KDEVOPS_POOL_PATH | awk '{print $1}')
	DELTA=0
	DELTA=$((EXISTING_USAGE_BYTES-AFTER_USAGE_BYTES))

	AFTER_USAGE=$(du -hs $KDEVOPS_POOL_PATH)
	echo -e "After prune disk usage:\n$AFTER_USAGE"
	if [[ $DELTA == "0" ]]; then
		echo "No disk savings after prune"
	else
		echo "Saved $DELTA bytes ( $((DELTA/1024/1024)) MiB or $((DELTA/1024/1024/1024)) GiB $((DELTA/1024/1024/1024/1024)) TiB)"
	fi
fi
