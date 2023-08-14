#!/bin/bash

# Enable job control
set -m

pynfs_versions="0 1"

# kick off jobs to run in the background in parallel
for version in $pynfs_versions; do
	cd ${PYNFS_DATA}/nfs4.${version}
	./testserver.py --json=${PYNFS_DATA}/pynfs-4.${version}-results.json --maketree --uid=0 --gid=0 ${NFSD_EXPORT}/${version}/pynfs/${ANSIBLE_HOST} all &
done

# wait for each to complete
for version in $pynfs_versions; do
	fg || true
done
