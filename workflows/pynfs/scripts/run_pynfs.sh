#!/bin/bash

# Enable job control
set -m

pynfs_versions="4.0 4.1"

# kick off jobs to run in the background in parallel
for version in $pynfs_versions; do
	cd ${PYNFS_DATA}/nfs${version}
	./testserver.py --json="${PYNFS_DATA}/pynfs-${version}-results.json" --maketree --uid=0 --gid=0 "${EXPORT_BASE}-${version}" all &
done

# wait for each to complete
for version in $pynfs_versions; do
	fg || true
done
