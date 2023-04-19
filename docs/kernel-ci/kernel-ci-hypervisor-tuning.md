# kernel-ci host hypervisor tuning

If you are using bare metal a few knobs can be enabled on the host acting as
the hypervisor which can save you a lot of RAM. Below we document a few of
these recommended system tuning parameters used and their rationale and how
you can easily take advantage of them on kdevops kernel-ci.

Before we review the technologies used, we should point out that the
architecture proposal for kernel-ci defines running many guests in parallel
using the same operating system image, using many binaries which are expected
to compile and end up with similar patterns on disk. Likewise, we expect a
a lot of data on disk which should be similar between guests. All guests
running the same test suite should in theory share a lot of similar run
time binaries on disk data.

To enable the hypervisor tunings to be set for within kdevops kernel-ci just
enable the kdevops configuration CONFIG_HYPERVISOR_TUNING. This will you
enable / disable  the different recommended hypervisor tuning parameters we
document below.

## Kernel same page merging

In one experiment enabling
[KSM](https://www.kernel.org/doc/html/latest/admin-guide/mm/ksm.html)
proved to save about about 40-70G of physical RAM. On a secondary kernel-ci
system, we have observed 135GiB of RAM savings after being enabled with the
kernel-ci workflow. To enable KSM just enable CONFIG_HYPERVISOR_TUNING_KSM.

Seeing the benefits of same page merging may take a while.

## Zswap

[Zswap](https://www.kernel.org/doc/html/latest/vm/zswap.html)
is a lightweight compressed cache for swap pages. Although in theory
designed for swap, you can enable zswap and still never touch disk, and only
use the benefit of zswap for compressing certain amount of memory. This
holds true so long as zswap doesn't actually evict pages from memory to
disk. We can verify this as follows:

```bash
cat /sys/kernel/debug/zswap/written_back_pages
0
```

In this case, 0 indicates that there is nothing from zswap touching disk.
Additionally, with the default setting of max pool percentage of 20%
it means zswap will use up to 20% of compressed pool in-memory total,
and once the amount of compressed pool in-memory used by zswap passes
this threshold it will start evicting to memory disk. We want to avoid
evicting to disk as much as possible, and so we recommend increasing this
to 90%. To enable zswap on kdevops just enable CONFIG_HYPERVISOR_TUNING_ZSWAP.
To use the recommended value enable for the max pool percent to try ensure
we avoid hitting disk with zswap just enable
CONFIG_HYPERVISOR_TUNING_ZSWAP_MAX_POOL_PERCENT and use the default we
recommend.
