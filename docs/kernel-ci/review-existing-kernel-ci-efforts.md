# Reviewing existing kernel-ci efforts

Below is a review of existing alternative kernel-ci efforts and should help
understand why we ended up implementing our own solution in light of our
listed requirements above.

The idea of kernel continuous integration (kernel-ci) is not new. The Linux
Foundation helps organize efforts around a generic
[kernel-ci](https://foundation.kernelci.org/mission-objectives/) effort,
however this is more designed towards embedded and specific target system
tests. It relies on a LAVA, Linaro Automated Validation Architecture. The
project home page to [LAVA](https://git.lavasoftware.org/lava/lava), mentions
"LAVA is an automated validation architecture primarily aimed at testing
deployments of systems based around the Linux kernel on ARM devices,
specifically ARMv7 and later." The [SOC](https://linux.kernelci.org/soc/)
page however now lists x86, but it is not the main focus of the project.
You can add a new test lab and add new tests, these tests are intended to
be public. If running tests for private consumption you'd have to set up
your own backend and front end. As it stands this project does not support
testing filesystems or the block layer.

The [Linux Kernel Functional Testing](https://lkft.linaro.org/) is another
effort, this uses "OpenEmbedded to build a userspace image, along with the
kernel, for each board and branch combination under test."

The [Intel 0-day](https://01.org/lkp/get--involved) service is another
example effort. The code is available as
[lkp-tests](https://github.com/intel/lkp-tests.git), for "Linux performance
tests". lkp-tests is perhaps more in line with what we would want, it even
has definitions for testing some filesytems. This project however is heavily
Ruby based, and does not provide bring up solutions, and does not support
any cloud soutions.

Then you have Ted Tso's
[xfstests-blkd](https://git.kernel.org/pub/scm/fs/ext2/xfstests-bld.git/) which
allows you to use Google Cloud Compute engine to run fstests. While a step in
the right direction this solution is obviously biased towards only one cloud
solution.

