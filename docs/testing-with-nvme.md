# Testing fstests with real NVMe drives

You may want to use real NVMe drives. That might be because you have new
NVMe drive technology or you want to use some real devices on the cloud or
on real bare metal systems.

kdevops support this with fstests by looking for nvme drives on /dev/disk/by-id/
symlinks. It first looks for eui symlinks but since not all drives supports
those a fallback is by default provided to look for model and serial number
symlinks.

Do not use this support if you are working on a real system because it will use
the first real NVMe drive found. It ignores all qemu NVMe drives.

You can either test using all NVMe drives, or using partitions on one NVMe
drive. This is all configurable in 'make menuconfig' and the documentation
for each feature is on its respective Kconfig file  help menu.
