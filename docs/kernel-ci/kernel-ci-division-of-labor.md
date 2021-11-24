# Appreciating kernel-ci division of labor

Testing is only 1/4th effort required to create confidence in a code base.
How do you properly record test failures? An even better question is how do
you make regressions very easy for developers to read. What about querying into
failures in an easy form? How do we scale? What are the odd issues we might have
not imagined or never tracked down? About 1/4 of the effort towards kernel-ci
so far has been implementing test design. Another 1/4th of the effort was how
to produce results and send reports. A full 1/4th of the effort is reporting
bugs, and the last 1/4th of the effort is hunting down, documenting and fixing
the really low hanging fruit of a test pipeline. It is worth documenting each
of these efforts separately so to create awareness of the different efforts
required and so they can properly be resourced if you are going to be adopting
a kernel-ci. Scaling kernel-ci requires serious consideration and attention of
this division of work.

## Making email reports for failure easy to read

The current methodology adopted by kdevops has been to embrace having a failure
represent itself as an entry into a file, with the option to add a comment for
a bugzilly entry. A new failure then can be as reported a diff to this file,
as in /usr/bin/diff, between an existing baseline of already known failures.
With this methodology a new regression then might look something like the
following in an email report:

[source,bash]
----
Date: Wed, 22 Sep 2021 16:29:58 +0200
From: kernel-ci@lists.suse.com
To: kernel-ci@lists.suse.com
Subject: [kernel-ci] 'kernel-ci on hadar linux-stable v5.14.4 on hadar: fstests on ext4 failure on test loop 42'

No failures detected by xunit:
Detected a failure as reported by differences in our expunge list
Test  42: FAILED!
== Test loop count 42
v4.3.1-188-g7e952a9
diff --git a/workflows/fstests/expunges/5.14.4/ext4/unassigned/ext4_defaults.txt b/workflows/fstests/expunges/5.14.4/ext4/unassigned/ext4_defaults.txt
index 372bc7c..a3e74c7 100644
--- a/workflows/fstests/expunges/5.14.4/ext4/unassigned/ext4_defaults.txt
+++ b/workflows/fstests/expunges/5.14.4/ext4/unassigned/ext4_defaults.txt
@@ -15,3 +15,4 @@ generic/566
 generic/587
 generic/600
 generic/601
+generic/622
----

In a kdevops setup with steady state set to 100, what this tells us is that
fstests test generic/622 failed after running fstests fully without failure
42 times. So in this case test generic/622 has a failure rate of about 1/42,
on kernel v5.14.4 for the ext4 filesystem.

The confidence in the baseline was shy 58 tests to complete the steady state
goal of 100 for v5.14.14 at this point. So we're about only half confident
in the baseline for v5.14.4 at this point given our the steady state of 100.

But is this good enough? For instance kunit ended up embracing the
[TAP (Test Anything Protocol)](https://testanything.org/) for results. Should we
try to get fstests, blktests and so on to also embrace it?

For now then collecting results remains a largely subjective aspect of kernel
testing for subsystems.

## A baseline with no bug references is useless

Creating a high confidence in a baseline is a great milestone. However, if no
one is looking into the issues found -- the expunges -- this is as good as
doing no testing. As such, while 1/4 of the work is to figure out how to create
a legible baseline for a series of tests so that developers can easily tell what
a failure might look like, another 1/4 of the work is to follow up and look at
the failure and report issues and then have someone look into them.  Some test
suites are more evolved, in the sense they may have already learned from the
growing pains from other older test suites, and provide a bit more information
to help with identifying what went wrong in a test. Some of these test suites
may make it easier to report issues and perhaps soon one day issues can
automatically be reported. For instance, fstests tracks failure with a test
number associated and a test-number.bad file if the outcome is different then
the expected output. This does not describe what the test does, nor does it
tell us anything, other than a failure occcurred.  When a kernel issue occurs
a test-number.dmesg file is created. fstests also supports providing test
results into an xunit file, and this file format actually contains the diff
in lines for an expected output. At times the xunit file may pick up on a
failure but no respective associated test-number.bad file may exist. Likewise
though, the xunit file may at times not tell us if a failure occurred but yet
we may still see a respective test-number.bad file present in test results.
And so we must not only look for dmesg files, and for all `*.bad` files, but we
must also look at the xunit results file for possible failures. To be clear,
just looking for `*.bad` files does not suffice to verify a failure did not
occur in a full run for fstests.

Run times for tests are kept in a file called check.time, an example few lines
follows:

```bash
$ head -4 workflows/fstests/results/sles15sp3-xfs-crc/5.3.18-219.g5219769-default/check.time
generic/001 3
generic/002 1
generic/003 12
generic/004 1
```

The above tells us that it took 3 seconds to run the test generic/001 for xfs
for the XFS configuration xfs-crc. Likewise it tells us it took 12 seconds to
run test generic/003.

kdevops creates an additional file, check.time.distribution, which helps
answer the question: How many tests take 1 second? How about 2 seconds? And
so on. This is done through the python script fstests-checktime-distribution.py.
The file is a CSV file representing time-segment,
number of tests which take this amount of time, and finally the last column
represents the percentage of tests which fall under this time distribution.

An example output from a real check.time.distribution file follows:

```bash
$ head -8 workflows/fstests/results/sles15sp3-xfs-crc/5.3.18-219.g5219769-default/check.time.distribution 
1,46,8.984375
2,174,33.984375
3,108,21.093750
4,34,6.640625
5,14,2.734375
6,11,2.148438
7,15,2.929688
8,10,1.953125
```

This tells us that 46 tests for XFS took 1 second to run, and that this
represents 8.9% of the all fstests run. Next, it tells us that 174 tests
took 2 seconds to run, and that this consisted of 33.98% of all tests
which ran. And so on. Most tests then for this test configuration and
filesystem take less than 2 seconds to run. We can find outliers at the
bottom of the list. This information might be useful if for example you
want to optimize a test environment so that only rapid tests are run, and
want to get a back of the napkin calculation of how much test coverage
you will be providing if you only include tests which take a certain amount
of time to run. It should be clarified that the amount of time it takes to
run a test is completely hardware / software specific, and so it only makes
sense in the exact same hardware / software configuration. However, it is
expected that if only different hardware is changes to the time values might
only change by a factor. So this information can be useful to engineer rapid
tests or to deal with tests which take a lot of time to be dealt with through
a secondary outlier service.

blktests makes it much easier understand a failure given that a test failure
records a description of the test purpose, the test status, the exit status,
run time. Additionally, a separate file is used for the bad output, and if a
kernel issue was detected an associated test-number.dmesg file is created. This
makes it extremely easy to strive to eventually automate creating a respective
bug entry for a regression, for example.

More work on fstests would be required to automate this sort of process.

Below is an example output failure, which turns out to be a blktests
failure present on SLES15-SP3 with a very low failure rate of about 1/642,
reported also upstream through
[korg#212305](https://bugzilla.kernel.org/show_bug.cgi?id=212305).

```bash
$ cat workflows/blktests/results/sles/15.3/nodev/block/009
status  fail
description     check page-cache coherency after BLKDISCARD
runtime 1.062s
reason  output
date    2021-03-04 00:03:17
exit_status     0
```

The respetive 009.out.bad follows:

```bash
$ cat workflows/blktests/results/sles/15.3/nodev/block/009.out.bad 
Running block/009
0000000 aaaa aaaa aaaa aaaa aaaa aaaa aaaa aaaa
*
0001000 0000 0000 0000 0000 0000 0000 0000 0000
*
2000000
0000000 0000 0000 0000 0000 0000 0000 0000 0000
*
2000000
Test complete
```

And finally we have the 009.full output:

```bash
cat workflows/blktests/results/sles/15.3/nodev/block/009.full 
wrote 33554432/33554432 bytes at offset 0
32 MiB, 16 ops; 0.0000 sec (270.549 MiB/sec and 135.2745 ops/sec)
wrote 10485760/10485760 bytes at offset 2097152
10 MiB, 5 ops; 0.0000 sec (1.934 GiB/sec and 990.0990 ops/sec)
8192+0 records in
8192+0 records out
33554432 bytes (34 MB, 32 MiB) copied, 0.173344 s, 194 MB/s
8+0 records in
8+0 records out
33554432 bytes (34 MB, 32 MiB) copied, 0.0950371 s, 353 MB/s
```

The baseline for SLE15-SP3 for virtual block devices is represented as follows:

```bash
cat workflows/blktests/expunges/sles/15.3/failures.txt 
block/001 # bsc#1191116 crashes
block/002 # bsc#1191117 scsi_debug cannot be removed
block/009 # bsc#1183392 failure rate 1/9
block/024 # bsc#1183395 failure rate 1/55
loop/002 # bsc#1183396 failure rate 1/4
```

## Consoles, system watchdogs and kdump

By default kdevops now enables setting up a console up so that kernel messages
are sent to it. Likewise, kdump is enabled on all target guests so to be able
to capture any kernel dumps in case of a kernel crash. Likewise kdevops also
now enables by default setting up the watchdog using
[systemd](https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html)

Three configuration options exist:

  * KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_RUNTIME: Configures the
    RuntimeWatchdogSec setting, default is 5 minute
  * KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_REBOOT: Configures the
    RebootWatchdogSec setting, default is 10 minutes
  * KDEVOPS_DEVCONFIG_SYSTEMD_WATCHDOG_TIMEOUT_KEXEC: Configures the systemd
    watchdog KexecWatchdogSec setting, default is 5 minutes.

One must be careful so that enough time is left to the system so that kdump
has enough time to do what it needs in case of a kernel crash. Finding this
sweet spot begs for a new test to be developed which tweaks amount of memory
on a guest, and how long it takes to run kdump given a failure. This will of
course depend on the type of storage used where kdump can write the kdump to.

## Test specific watchdogs

Often, the systemd watchdog won't pick up on failures with fstests or blktests
which we might want to find out about. For instance, sometimes a hang can occur
on a test but there might be no indications on the kernel ring buffer that a
soft lockup ocurred, the issue might be elsewhere. For this reason kdevops
kernel-ci enables the implementation of test specific watchdogs. Two test
specific watchdogs have been developed in kdevops as examples. One for fstests,
scripts/workflows/fstests/fstests_watchdog.py, and
another for blktests, scripts/workflows/blktests/blktests_watchdog.py.

These test specific watchdogs can also be used to query the live status of an
existing test. Results are provided in realtime. Below is an example real world
output with fstests, in this case no prior tests had been run before this one,
and so we cannot compute the estimated completion percentange.

```bash
./scripts/workflows/fstests/fstests_watchdog.py hosts baseline
                           Hostname           Test-name        Completion %          runtime(s)     last-runtime(s)   Stall-status                        Kernel
                  sles12sp5-xfs-crc         generic/476                  0%                  38                   0             OK  4.12.14-532.g8ba3772-default
                sles12sp5-xfs-nocrc         generic/475                  0%                  22                   0             OK  4.12.14-532.g8ba3772-default
            sles12sp5-xfs-nocrc-512         generic/269                  0%                 999                   0             OK  4.12.14-532.g8ba3772-default
               sles12sp5-xfs-logdev         generic/416                  0%                  11                   0             OK  4.12.14-532.g8ba3772-default
```

The above results tell us the test that each target host is running, the
respective kernel and how long that test has taken so far. If a prior
check.time is known then we can compute the completion percetage as in the
following example:

```bash
./scripts/workflows/fstests/fstests_watchdog.py hosts baseline
                           Hostname           Test-name        Completion %          runtime(s)     last-runtime(s)   Stall-status                        Kernel
            sles12sp5-ext4-defaults            ext4/033                  8%                   1                  13             OK  4.12.14-519.g881827a-default
```

You can configure these test specific watchdogs so that if communication
in querying a test status cannot be obtained within a specific amount of time
the host can be considered hung. Another option exists which will kill the
current test if one of these hang conditions are detected, and send a report.
Without this we can often end up in a situation where a test will hang and
never complete. Without these test specific watchodgs we would not know of
some type of failure unless a user was manually watching / monitoring the
guest on a regular basis.

## Low hanging fruit examples

Failures which are rare tend to eventually catch up to us and disrupt the
development of a baseline. Below are some examples. Some are yet to be
investigated. They end up accruing as technical debt. Without these issues
being resolved, kernel-ci either fails randomly due to these known odd
unexplained failures or we simply ignore the test and never run the test
again.

We need to address these low hanging fruit failures otherwise the technical
debt increases and makes it pretty difficult to grow confidence in a baseline.

### Unresolved block layer issues

As has been documented some tests such as blktests block/009 is known to
currently fail upstream on linux-next with a failure rate of about 1/642
as documented through
[korg#212305](https://bugzilla.kernel.org/show_bug.cgi?id=212305). What are
these rare sporadic issues that cause this test to fail?

### scsi_debug cannot be removed failure

fstests and blktests are example test suites which heavily rely on module
removal. Some kernel maintainers have incorrectly taken stances that
module removal is best effort, this is not true. This is specially true in
light of how we rely on it for testing purposes. But this also means we need to
address all possible corner cases issues with module removal as well, and it
would seem at least one corner case issue with module removal has ended up
piling up as technical debt toward testing with both fstests and blktests.

Some of the low failure rates issues are very difficult to debug. Such was the
case with generic/108 with a failure rate of 1/36 on btrfs and xfs/279 with
different failure rates depending on the XFS configuration used:

  * xfs_crc: 1/133
  * xfs_nocrc: 1/41
  * xfs_nocrc_512: 1/17
  * xfs_reflink: 1/775
  * xfs_reflink_1024: 1/471
  * xfs_reflink_normapbt: 1/170

These tests were also failing for btrfs and ext4. It turns out that all of
these issues were related. This happens because the scsi_debug module cannot be
removed. But why? Research into the issue specifically on the scsi_debug
through the [korg#212337](https://bugzilla.kernel.org/show_bug.cgi?id=212337)
lead to inconclusive results with failure rates as low as 1/1642 with
linux-next. Finally, generalizing the test generic/108 in a standalone manner,
making the test independent of fstests, and picking any filesystem at random
through the effort in
[korg#214015](https://bugzilla.kernel.org/show_bug.cgi?id=214015) revealed that
this issue is a generic userspace / kernel module issue which has been present
for years, and was only considered theoretical years ago.

The way the theoretical race was handled long ago was using a module remover
wait logic in the kernel. This wait logic was considered complex and since the
race was considered theoretical the kernel's module removal wait logic was
ripped out of the kernel and replaced with a userspace rmmod 5 second wait.
That userspace rmmod 5 second wait was eventually also removed and never
was implemented in modprobe.

A module refcount is finicky. For example, for block devices any `blkdev_open()`
call will bump the module refcnt. You can easily create a race with the module
refcnt and module removal by opening the file descriptor to a block device,
sleeping and racing with module removal. The only way to properly deal with this,
since we don't want to add complexity to the kernel, is to implement a proper
patient module removal support on kmod, which in turn can be used by modprobe
and rmmod with a new -p argument. A respective open coded solution needed to
also be implemented for fstests and blktests for cases where the new patient
module remove is not supported yet. Patches have been proposed and are being
reviewed for integration into kmod. The respective open coded implementation
for fstests is now merged, and a respective blktests development patch is in
the works.

Fixing this should not only deal with races on module removal with scsi_debug
but with perhaps many more drivers which are loaded / removed on a test's
whims.

### Reboot-limit

How many times should reboot work for guest in such a way that after reboot
ssh access is guaranteed to work? Sporadic failures with this simple concept
are possible and remain a pain for kernel-ci. We are investigating the issue
on OpenSUSE through
[bsc#1190632](https://bugzilla.opensuse.org/show_bug.cgi?id=1190632) but the
current suspect was that the issue is ansible ssh commands somehow
get dropped and since the default is no retries a timeout obviously can occur.
