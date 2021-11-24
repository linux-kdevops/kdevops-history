# Seeing more issues with loopback / truncated files setup

When testing with fstests the kdevops architecture has proven to find more
issues than with a regular bare metal setup.

If using bare metal we have to consider that the host has its own filesystem.
And if using virtualization behind the scenes we then have the filesystem where
the OS for the guest will placed and the sparse files which will be used by each
guest for its virtual nvme drives. Then the guest may use another filesystem for
the /media/sparsefiles/ mount point. And finally there is the target filesystem
which is going to be tested.

Our expectations to see more issues with fstests when using loopback devices
and spare files kdevops when testing with fstests has proven to be true, some
of the bugs reported with kdevops are not easily reproduced by filesystem
developers otherwise, and so the extra development guests which can be set up
with CONFIG_KDEVOPS_BASELINE_AND_DEV have proven to be valuable to allow
developers to reproduce the issue easily. This setup tends to expose more
filesystem bugs than a direct real hardware setup.
