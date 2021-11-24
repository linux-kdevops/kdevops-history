# kernel-ci host requirements

We want a host which can support as many guests as possible. Since each virtual
CPU corresponds to a regular process on the host, so long as we have enough
threads we should be able to properly parallelize work.

Our limiting factor will actually be the RAM on the host. The more memory
we can get the more guests we can spawn and the more tests we can run. A
baremetal hypervisor starter system should consist of about 128 threads, 128
GiB RAM.

The hypervisor however should also have at least enough threads to run
the guests, and handle local IO. So we have to reserve at least a few
threads and RAM for the hypervisor.

Currently available 128 hyper threaded systems are either the Intel Xeon Phi
Knights Landing, or the AMD EPYC 7702P. The Knights Landing architecture
provides 4 threads per core, while the AMD EPYC 7702P provides 2 threads per
core. The Intel Xeon Phi Knights Landing systems support up to 384 GiB of RAM,
using 6 DDR4 slots, and so a maximum of 64 GiB per DDR4 slot. The AMD EPYC 7702P
supports up to 512 GiB RAM using 8 DDR4 slots.

## kernel-ci host storage requirements

Our host storage requirements are driven by our own requirements to run
guests and their own storage requirements. We want to reduce latency on
IO, and so a fast local commodity storage mechanism is desirable.

We know that on average each guest will require about 192 GiB of storage,
with 16 guests that is about at least 3 TiB of space for all 16 guests.

In order to simplify the storage architecture we can simply rely on
3 TiB NVMe storage drives dedicated towards the guests. Our latest
hypervisors however have two separate 6 TiB NVMe drives each.

## kernel-ci host example fstests for one filesystem

The following is an example of test configuration requirements for just
testing one filesystem, in this case XFS. Keep in mind we will be testing
all supported filesystems.

![kernel-ci-xfs-host](images/kernel-ci-host-xfs.png)

## kernel-ci host requirements diagram

The following is what this ends up looking like for the kernel-ci host:

![kernel-ci-host](images/kernel-ci-host.png)
