#!/bin/bash
# Creates a few 20 GiB truncate files we'll use as our disks for testing.
# A loopback device is used for each of them. This allows us to save space
# and deploy the test on any system.

SIZE="20G"

if [ -z "$OSCHECK_SETUP_SYSTEM" ]; then
	OSCHECK_TRUNCATE_PATH=/media/truncated/
fi

mkdir -p $OSCHECK_TRUNCATE_PATH

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

if [ $# -eq 1 ]; then
	if [ $1 = "-d" ]; then
		delete_loops
		rm -rf $OSCHECK_TRUNCATE_PATH/disk-sdc*
	fi
fi

if [ ! -d $OSCHECK_TRUNCATE_PATH ]; then
	mkdir -p $OSCHECK_TRUNCATE_PATH
	if [ ! -d $OSCHECK_TRUNCATE_PATH ]; then
		echo "Directory could not be created: $OSCHECK_TRUNCATE_PATH"
		exit 1
	fi
fi

for i in $(seq 5 16); do
	DISK=$OSCHECK_TRUNCATE_PATH/disk-sdc$i
	LOOPDEV=/dev/loop$i
	if [ ! -e $DISK ]; then
		truncate -s $SIZE $DISK
		echo "$DISK ($SIZE) is now setup"
	fi
	if [ -e $LOOPDEV ]; then
		setup_loop $LOOPDEV $DISK
	else
		mknod $LOOPDEV b 7 $i
		setup_loop $LOOPDEV $DISK
	fi
done

echo "Reminder: fstests requires you to run mkfs your TEST_DEV variable"
echo "this may typically be $LOOPDEV"
