# Viewing archived results from fstests

For example to view mcgrof's results of testing XFS on linux-next tag
next-20230725 on a libvirt setup you can use:

```
tar -tOJf workflows/fstests/results/mcgrof/libvirt-qemu/20230727/6.5.0-rc3-next-20230725.xz
```
## Viewing specific test files

For example to see all generic/175 failures:

```                                                                                
tar -tOJf workflows/fstests/results/mcgrof/libvirt-qemu/20230727/6.5.0-rc3-next-20230725.xz 2>&1 | grep generic | grep 175
6.5.0-rc3-next-20230725/xfs_reflink_normapbt/generic/175.out.bad
6.5.0-rc3-next-20230725/xfs_reflink_normapbt/generic/175.full
6.5.0-rc3-next-20230725/xfs_reflink_normapbt/generic/175.dmesg
6.5.0-rc3-next-20230725/xfs_reflink/generic/175.out.bad
6.5.0-rc3-next-20230725/xfs_reflink/generic/175.full
6.5.0-rc3-next-20230725/xfs_reflink/generic/175.dmesg
6.5.0-rc3-next-20230725/xfs_reflink_4k/generic/175.out.bad
6.5.0-rc3-next-20230725/xfs_reflink_4k/generic/175.full
6.5.0-rc3-next-20230725/xfs_reflink_4k/generic/175.dmesg
6.5.0-rc3-next-20230725/xfs_rtdev/generic/175.out.bad                          
6.5.0-rc3-next-20230725/xfs_rtdev/generic/175.full
6.5.0-rc3-next-20230725/xfs_rtdev/generic/175.dmesg
```

## See one individual file

```                                                                                
tar -xOJf workflows/fstests/results/mcgrof/libvirt-qemu/20230727/6.5.0-rc3-next-20230725.xz 6.5.0-rc3-next-20230725/xfs_reflink_normapbt/generic/175.out.bad
tar -xOJf workflows/fstests/results/mcgrof/libvirt-qemu/20230727/6.5.0-rc3-next-20230725.xz 6.5.0-rc3-next-20230725/xfs_reflink_normapbt/generic/175.dmesg
```

