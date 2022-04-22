#!/bin/bash

export TOPDIR=$PWD

source $TOPDIR/scripts/workflows/fstests/ext4/lib.sh
source $TOPDIR/scripts/workflows/fstests/btrfs/lib.sh
source $TOPDIR/scripts/workflows/fstests/xfs/lib.sh

echo "ext4   sections: $EXT4_SECTIONS"
echo "xfs    sections: $XFS_SECTIONS"
echo "btrfs  sections: $BTRFS_SECTIONS"
