#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# Where we stuff the extra arguments we don't understand to fio
declare -a EXTRA_FIO_ARGS

VERBOSE=""

BLOCKSIZE=""
PHYSICAL_BLOCK_SIZE=""
MAX_SIZE=""
TARGET=""
JOBS=""

ALIGNED_PBS_BLOCKS=""
ALIGNED_BS_PER_BLOCK=""

ALIGNED_BLOCKS=""
ALIGNED_BLOCKS_JOBS=""
UNALIGNED_BLOCKS_JOBS=""

ALIGNED_JOBS=""
UNALIGNED_JOBS=""

ALIGNED_BLOCK_BYTES=""
TOTAL_ALIGNED_BLOCK_BYTES=""
REMAINDER_BLOCK_BYTES=""

# For the default IO we use we want the optimal IO, it should already be
# aligned to the logical block size. We should review what userspace has
# used since the old days first though.
#
# We have stat-size.h in gnulib:
#
# https://github.com/coreutils/gnulib/blob/master/lib/stat-size.h
#
# In userspace gnulib is used by coreutils stat binary. In gnulib stat-size.h
# first there is DEV_BSIZE with BSIZE and BBSIZE inheritence from unix but this
# is ancient and has a default of 4096 bytes if neither of these are defined.
# Then we have STP_BLKSIZE(stat) which gets us the st_blksize with a current
# arbitrary limitation of SIZE_MAX / 8 + 1 (512 MiB 64-bit). That is with
# stat --format="%o". This suffices for us today, even if you use a large block
# size filesystem, you get what you expect, the filesystem block size instead of
# the logical block size. So stat() and using st_blksize suffices for files.
#
# The same stat call on block devices will get the logical block size and so we
# must cat the actual queue's physical block size to ensure to avoid any
# read-modify-write implications, but we can do better for block devices if
# want to use a default target block size: the real optiomal IO. Even though
# userspace stat says that $(stat --format="%o" gets the optimal IO size, this
# is not that accurate. Since userspace has adopted st_blksize for optimal IO
# though we should evaluate with the community if we should have parity and also
# use the physical block size for block devices when the physical block device >
# logical block device so to bring parity on strategy for both block device and
# files.  An example existing set of devices would be devices which are exposed
# in the cloud with a large atomic and smaller logical block size. On NVMe it
# would be those NVMe drives with a larger atomic as well.
#
# We also have the new direct IO STATX_DIOALIGN but is useless as it returns 512
# bytes even on files when the block size on the filesystem is larger on XFS.
# It is however is useful to tell if a block device or filesystem supports
# direct IO, but only for filesystems which support it. So we should fix it.
#
# The physical block size is always larger and a power of 2 than the logical
# block size and so always aligned to the logical block size. It also ensures
# we avoid read-modify-writes, and so we refer to it for the alignment
# constraint we want to consider.

usage()
{
	echo "$0 - wrapper for fio to prefill"
	echo "--help           - Shows this menu"
	echo "--target         - Required either truncated file or target block device file such as /dev/nvme0n1"
	echo "--blocksize      - Use this as the max blocksize in fio"
	echo "--max-size       - Use this as the either the drive's max capacity or file size instead"
	echo "--physical-bs    - Use this as the drive's physical block size instead"
	echo "--verbose        - Be verbose when debugging"
	echo "--jobs           - How many threads to consider"
	echo "--help           - Print help menu"
	echo ""
	echo "Examples:"
	echo ""
	echo "Uses 2 MiB to pre-fill an NVMe drive:"
	echo "$0 --target /dev/nvme0n1 --blocksize 2097152"
	echo ""
	echo "The physical block size represents the size to align writes to"
	echo "so to avoid read-modify-writes on flash storage."
	echo ""
	echo "If a block device is given then by default:"
	echo "  - we use the drive's queue/optimal_io_size for blocksize if"
	echo "    it is not zero, otherwize we use the physical block size"
	echo "  - we use the drive's capacity as the max size."
	echo "  - we use the drive's physical block size for its physical block size"
	echo ""
	echo "If a regular file is given then by default:"
	echo "  - we use the file's returned st_blksize from stat() for both the"
	echo "    block size and physical block as gathered with:"
	echo "    stat printf=\"%o\" file"
	echo "  - we compute the max size as the file's size."
	echo ""
	echo "Note that all parameters which we do not understand we'll just"
	echo "pass long to fio so it can use them."
}

copy_to_fio_extra_args()
{
	FIO_EXTRA_ARGS+=" $1"
}

debug()
{
	echo "target: $TARGET"
	echo "pbs: $PHYSICAL_BLOCK_SIZE"
	echo "size: $MAX_SIZE"
	echo "bs: $BLOCKSIZE"
	echo "jobs: $JOBS"
	echo ""
	echo "aligned-pbs-blocks: $ALIGNED_PBS_BLOCKS"
	echo "aligned-bs-per-block: $ALIGNED_BS_PER_BLOCK"
	echo ""
	echo "aligned-blocks: $ALIGNED_BLOCKS"
	echo "aligned-block-jobs: $ALIGNED_BLOCKS_JOBS"
	echo "unaligned-block-jobs: $UNALIGNED_BLOCKS_JOBS"
	echo ""
	echo "aligned-jobs: $ALIGNED_JOBS"
	echo "unaligned-jobs: $UNALIGNED_JOBS"
	echo ""
	echo "aligned-bytes-per-job: $ALIGNED_BLOCK_BYTES"
	echo "total-aligned-bytes: $TOTAL_ALIGNED_BLOCK_BYTES"
	echo "remainder--block-bytes: $REMAINDER_BLOCK_BYTES"
	if [[ "$((TOTAL_ALIGNED_BLOCK_BYTES + REMAINDER_BLOCK_BYTES))" != "$MAX_SIZE" ]]; then
		echo "total-aligned-bytes + remainder-block-bytes != size ------> BUG!"
	else
		echo "total-aligned-bytes + remainder-block-bytes == size ------> OK!"
	fi
	echo ""
	echo ""
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--target)
			TARGET="$2"
			shift
			shift
			;;
		--blocksize)
			BLOCKSIZE="$2"
			shift
			shift
			;;
		--max-size)
			MAX_SIZE="$2"
			shift
			shift
			;;
		--physical-bs)
			PHYSICAL_BLOCK_SIZE="$2"
			shift
			shift
			;;
		--verbose)
			VERBOSE="true"
			shift
			;;
		--jobs)
			JOBS="$2"
			shift
			;;
		--help)
			usage
			exit 0
			;;
		*)
			copy_to_fio_extra_args $key
			shift
			;;
		esac
	done
}

parse_args $@

if [[ "$TARGET" == "" ]]; then
	echo "You need to specify --target"
	echo ""
	usage
	exit 1
fi

if [[ "$JOBS" == "" ]]; then
	JOBS="$(nproc)"
fi

if [[ -b $TARGET ]] then
	if [[ $(id -u) != "0" ]]; then
		echo "Must be root to work on block devices"
		exit
	fi

	DEVNAME="$(basename $TARGET)"
	PBS_FILE="/sys/block/$DEVNAME/queue/physical_block_size"
	MAX_IO_FILE="/sys/block/$DEVNAME/queue/optimal_io_size"

	if [[ ! -f $PBS_FILE ]]; then
		echo "Not found: $PBS_FILE"
		exit 1
	fi

	if [[ ! -f $MAX_IO_FILE ]]; then
		echo "Not found: $MAX_IO_FILE"
		exit 1
	fi

	BDEV_PHYSICAL_BLOCK_SIZE="$(cat $PBS_FILE)"
	BDEV_MAX_IO="$(cat $MAX_IO_FILE)"
	BDEV_MAX_SIZE="$(/usr/sbin/blockdev --getsize64 $TARGET)"

	if [[ "$PHYSICAL_BLOCK_SIZE" == "" ]]; then
		PHYSICAL_BLOCK_SIZE=$BDEV_PHYSICAL_BLOCK_SIZE
	fi

	if [[ "$BLOCKSIZE" == "" ]]; then
		if [[ "$BDEV_MAX_IO" != "0" ]]; then
			BLOCKSIZE=$BDEV_MAX_IO
		else
			BLOCKSIZE=$PHYSICAL_BLOCK_SIZE
		fi
	fi

	if [[ "$MAX_SIZE" == "" ]]; then
		MAX_SIZE=$BDEV_MAX_SIZE
	fi
elif [[ -f $TARGET ]] then
	echo "Implement me"
	exit 1
else
	echo "Target must be a block device or file"
	echo ""
	usage
	exit 1
fi

# These get natural numbers on purpose, we round down
ALIGNED_PBS_BLOCKS="$((MAX_SIZE / PHYSICAL_BLOCK_SIZE))"
UNALIGNED_PBS_BLOCKS="$((MAX_SIZE % PHYSICAL_BLOCK_SIZE))"
if [[ "$UNALIGNED_PBS_BLOCKS" != "0" ]]; then
	echo "Odd, capacity not aligned to physical block size"
	echo ""
	echo "$MAX_SIZE % $PHYSICAL_BLOCK_SIZE = $UNALIGNED_PBS_BLOCKS"
	echo ""
	echo "It should be:"
	echo "$MAX_SIZE % $PHYSICAL_BLOCK_SIZE = 0"
	exit 1
fi

ALIGNED_BS_PER_BLOCK="$((BLOCKSIZE / PHYSICAL_BLOCK_SIZE))"
UNALIGNED_BS_PER_BLOCK="$((BLOCKSIZE % PHYSICAL_BLOCK_SIZE))"
if [[ "$UNALIGNED_BS_PER_BLOCK" != "0" ]]; then
	echo "Odd, block size not aligned to physical block size. We have:"
	echo ""
	echo "$BLOCKSIZE % $PHYSICAL_BLOCK_SIZE = $UNALIGNED_BS_PER_BLOCK"
	echo ""
	echo "It should be:"
	echo "$BLOCKSIZE % $PHYSICAL_BLOCK_SIZE = 0"
	exit 1
fi

# These are the number of blocks at blocksize which are aligned to the
# physical block size. We need next to divid this by the number of jobs
# we have been asked to use.
ALIGNED_BLOCKS="$((ALIGNED_PBS_BLOCKS / ALIGNED_BS_PER_BLOCK))"

# We expect capacity / jobs to not always be aligned to the target block size
# we want to operate, and so we must work with a different block size which
# does align to the block device or file for that task. Only one thread is used
# here by default as it should be a small amount of data.
CHECK_UNALIGNED_BLOCKS_JOBS_MAX="$((ALIGNED_BLOCKS % JOBS))"
if [[ "$CHECK_UNALIGNED_BLOCKS_JOBS_MAX" == 0 ]]; then
	ALIGNED_BLOCKS_JOBS="$CHECK_UNALIGNED_BLOCKS_JOBS_MAX"
	UNALIGNED_BLOCKS_JOBS=""
	ALIGNED_JOBS=$JOBS
	UNALIGNED_JOBS="0"
else
	UNALIGNED_JOBS="1"
	ALIGNED_JOBS="$((JOBS - UNALIGNED_JOBS))"
	ALIGNED_BLOCKS_JOBS="$((ALIGNED_BLOCKS / ALIGNED_JOBS))"
	UNALIGNED_BLOCKS_JOBS="$((ALIGNED_BLOCKS % ALIGNED_JOBS))"
fi

# This is the amount of bytes each thread which is working on aligned blocksize.
# The $ALIGNED_JOBS can be used for this.
ALIGNED_BLOCK_BYTES="$((ALIGNED_BLOCKS_JOBS * BLOCKSIZE))"

TOTAL_ALIGNED_BLOCK_BYTES="$((ALIGNED_BLOCK_BYTES * $ALIGNED_JOBS))"

# This should be dealt with on a separate fio task with $UNALIGNED_JOBS jobs.
# It may be that we don't need it, if the stars aligned too.
REMAINDER_BLOCK_BYTES="$((MAX_SIZE - $TOTAL_ALIGNED_BLOCK_BYTES))"

CHECK_UNALIGNED_BLOCK_BYTES="$((ALIGNED_BLOCK_BYTES % BLOCKSIZE))"
if [[ "$CHECK_UNALIGNED_BLOCK_BYTES" != "0" ]]; then
	echo "The entire job each thread should work on should be aligned to the target blocksize"
	echo "We got:"
	echo "$ALIGNED_BLOCK_BYTES % $BLOCKSIZE = $CHECK_UNALIGNED_BLOCK_BYTES"
	exit 1
fi

CHECK_UNALIGNED_BLOCK_BYTES_PBS="$((ALIGNED_BLOCK_BYTES % PHYSICAL_BLOCK_SIZE))"
if [[ "$CHECK_UNALIGNED_BLOCK_BYTES_PBS" != "0" ]]; then
	echo "The entire job each thread should work on should be aligned to the target physical block size"
	echo "We got:"
	echo "$ALIGNED_BLOCK_BYTES % $PHYSICAL_BLOCK_SIZE = $CHECK_UNALIGNED_BLOCK_BYTES_PBS"
	exit 1
fi

if [[ "$REMAINDER_BLOCK_BYTES" != "0" ]]; then
	# We only care about aligning to the physical block size, as the
	# data remaining could be smaller than the desired block size.
	CHECK_UNALIGNED_REMAINDER_BLOCK_BYTES_PBS="$((REMAINDER_BLOCK_BYTES % PHYSICAL_BLOCK_SIZE))"
	if [[ "$CHECK_UNALIGNED_REMAINDER_BLOCK_BYTES_PBS" != "0" ]]; then
		echo "The entire job each thread should work on should be aligned to the target physical block size"
		echo "We got:"
		echo "$REMAINDER_BLOCK_BYTES % $PHYSICAL_BLOCK_SIZE = $CHECK_UNALIGNED_REMAINDER_BLOCK_BYTES_PBS"
		exit 1
	fi
fi

if [[ "$VERBOSE" == "true" ]]; then
	debug
fi

if [[ "$UNALIGNED_JOBS" == "0" && "$REMAINDER_BLOCK_BYTES" != "0" ]]; then
	echo "If we have no unaligned jobs to run the remainder block bytes should be 0 too."
	echo
	debug
	exit 1
fi

if [[ "$((TOTAL_ALIGNED_BLOCK_BYTES + REMAINDER_BLOCK_BYTES))" != "$MAX_SIZE" ]]; then
	echo "Unexpected computation, this $0 is buggy..."
	echo
	debug
	exit 1
fi

# This would be the manual math we'd do with the fio output to verify
# correctness, so just do that before giving the output.
FIO_SUM_TOTAL_BYTES="$(((ALIGNED_BLOCK_BYTES * ALIGNED_JOBS) + REMAINDER_BLOCK_BYTES))"
if [[ "$FIO_SUM_TOTAL_BYTES" != "$MAX_SIZE" ]]; then
	echo "Unexpected final result $0 is buggy..."
	echo "We expected ( $ALIGNED_BLOCK_BYTES * $ALIGNED_JOBS) + $REMAINDER_BLOCK_BYTES == $MAX_SIZE"
	echo "We got ( $ALIGNED_BLOCK_BYTES * $ALIGNED_JOBS) + $REMAINDER_BLOCK_BYTES == $FIO_SUM_TOTAL_BYTES"
	echo
	debug
	exit 1
fi

if [[ "$VERBOSE" == "true" ]]; then
	echo "Fio command for all aligned data at blocksize $BLOCKSIZE using $ALIGNED_JOBS jobs":
	echo ""
fi

# XXX: use only memory  for --alloc-size based on the amount of memory actually
# needed per job. This default of 1 GiB should get us up to 128 threads for now.
FIO_CMD="fio --filename=$TARGET -direct=1 -name drive-pre-fill-aligned-to-bs "
FIO_CMD="$FIO_CMD --readwrite=write --ioengine=io_uring --group_reporting=1 "
FIO_CMD="$FIO_CMD --alloc-size=1048576 --numjobs=$ALIGNED_JOBS"
FIO_CMD="$FIO_CMD --offset_increment=$ALIGNED_BLOCK_BYTES --size=$ALIGNED_BLOCK_BYTES "
FIO_CMD="$FIO_CMD --blocksize=$BLOCKSIZE "

echo $FIO_CMD $EXTRA_FIO_ARGS

if [[ "$VERBOSE" == "true" ]]; then
	echo ""
	echo "Fio command for all remaining data which needs to be issued at $PHYSICAL_BLOCK_SIZE":
	echo ""
fi

if [[ "$UNALIGNED_JOBS" != "0" ]]; then
	FIO_CMD="fio --filename=$TARGET -direct=1 -name drive-pre-fill-aligned-to-pbs "
	FIO_CMD="$FIO_CMD --readwrite=write --ioengine=io_uring --group_reporting=1 "
	FIO_CMD="$FIO_CMD --offset=$TOTAL_ALIGNED_BLOCK_BYTES --size=$REMAINDER_BLOCK_BYTES"
	FIO_CMD="$FIO_CMD --blocksize=$PHYSICAL_BLOCK_SIZE"
	echo $FIO_CMD $EXTRA_FIO_ARGS
fi
