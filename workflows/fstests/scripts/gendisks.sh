#!/bin/bash

# Creates a 11 sparse files files we'll use as our disks for testing.
# A loopback device is used for each of them. This allows us to save space
# and deploy the test on any system.

test -s common/config && . common/config || true

CREATE_TEST_DEV="n"

setup_loop()
{
	LOOPDEV=$1
	DISK=$2

	losetup $LOOPDEV 2>/dev/null
	if [ $? -ne 0 ]; then
		losetup $LOOPDEV $DISK
		if [ $? -eq 0 ]; then
			echo "$LOOPDEV ready"
		fi
	else
		echo "$LOOPDEV was previously already setup an is ready"
	fi
}

delete_loops()
{
	for i in $(losetup -a | awk -F ":" '{print $1}'); do
		losetup -d $i
	done
}

gendisk_usage()
{
	echo "$0 - helps you create disks using truncated files on loopback disks"
	echo "--help          - Shows this menu"
	echo "-d              - Delete old files remove old loopback devices"
	echo "-m              - Create the TEST_DEV filesystem for you, requires FSTYP set and TEST_DEV set on your configuration file"
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		-d)
			delete_loops
			rm -rf $FSTESTS_SPARSE_FILE_PATH/disk-sdc*
			shift
			;;
		-m)
			if [[ -f common/config ]]; then
				SECTION=$(echo $HOSTNAME | sed -e 's|-dev||')
				SECTION=$(echo $SECTION | sed -e 's|-|_|g')
				SECTION=$(echo $SECTION| awk -F"_" '{for (i=2; i <= NF; i++) { printf $i; if (i!=NF) printf "_"}; print NL}')
				parse_config_section $SECTION
				echo "Section: $SECTION with TEST_DEV: $TEST_DEV and MKFS_OPTIONS: $MKFS_OPTIONS"
			fi
			CREATE_TEST_DEV="y"
			if [ ! -z $TEST_DEV ]; then
				umount $TEST_DEV
			fi
			shift
			;;
		--help)
			gendisk_usage
			exit
			;;
		*)
			echo -e "Uknown option: $key\n"
			gendisk_usage
			exit
			;;
		esac
	done
}

parse_args $@

if [ ! -d $FSTESTS_SPARSE_FILE_PATH ]; then
	mkdir -p $FSTESTS_SPARSE_FILE_PATH
	if [ ! -d $FSTESTS_SPARSE_FILE_PATH ]; then
		echo "Directory could not be created: $FSTESTS_SPARSE_FILE_PATH"
		exit 1
	fi
fi

if [ "$FSTESTS_TESTDEV_SPARSEFILE_GENERATION" != "y" ]; then
	echo "Skipping sparse file generation because CONFIG_FSTESTS_TESTDEV_SPARSEFILE_GENERATION is disabled"
	exit
fi

for i in $(seq 5 16); do
	DISK="${FSTESTS_SPARSE_FILE_PATH}/${FSTESTS_SPARSE_FILENAME_PREFIX}${i}"
	LOOPDEV=/dev/loop$i
	if [ ! -e $DISK ]; then
		truncate -s $FSTESTS_SPARSE_FILE_SIZE $DISK
		echo "$DISK ($FSTESTS_SPARSE_FILE_SIZE) is now setup"
	fi
	if [ -e $LOOPDEV ]; then
		setup_loop $LOOPDEV $DISK
	else
		mknod $LOOPDEV b 7 $i
		setup_loop $LOOPDEV $DISK
	fi
done

if [ "$CREATE_TEST_DEV" != "y" ]; then
	echo "Skipping initial $TEST_DEV mkfs"
else
	error="no"
	if [ -z $FSTYP ]; then
		echo "FSTYP environment variable is required to be set when the -m argument is used"
		error="yes"
	fi
	if [ -z $TEST_DEV ]; then
		echo "TEST_DEV environment variable is required to be set when the -m argument is used"
		echo "TEST_DEV: $TEST_DEV"
		error="yes"
	fi
	if [ "$error" == "yes" ]; then
		exit 1
	fi
	CMD="mkfs.$FSTYP $MKFS_OPTIONS $TEST_DEV"
	echo "$CMD"
	$CMD
fi
