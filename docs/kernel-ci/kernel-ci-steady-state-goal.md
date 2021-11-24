# Test failure rates

Running a single test once without failure does not necessarily mean that the
test will never fail. There are certain conditions which may help to trigger a
failure such as time, memory pressure, and random system conditions and
obviously in the worst luck's case cosmic rays. Using the same logic, running
for example a full set of tests with test suites such as fstests or blktests
without failure does not necessarily mean that a failure with any of the tests
run cannot happen.

For example blktests block/009 was known to fail for a few older kernels,
refer to [korg#212305](https://bugzilla.kernel.org/show_bug.cgi?id=212305)
for details. It took running the test 669 times in a row before the test
failed. We refer to the initial failure rate of this test then as 1/669. If
we run the test again and we hit a failure on this test on test number 614 we
then have to average out the failure rate and so get 1/641.5 or 1/642.

Getting no failures on one run of fstests or blktests is not a good way
to ensure there are no regressions. Failure rate needs to be considered.

## Average time for a new kernel release

If you run a test succesfully without failure 100 times then your success
rate is 100/100 or 1. Our success rate must be as close as posible to 1 and
failure rate show be as close to 0 as possible. To avoid regressions we must
run a test the maximum amount of times as is possible, so to gain confidence
in our success rate and reduce our failure rate for a test. If the success rate
is lower than our allowed tolerable failure rate for a kernel release we have
failed. 

This begs the question of what the allowable failure rate for tests should be
for any kernel release. Since tests are tied to test suites, and system
resources used to run kernel continous integration it makes sense to define
allowable failure rate for a release based on allowable system resources to
test a release. That is, to be clear, you work with what you have. The more
system resources you have dedicated towards a kernel-ci system, the higher the
confidence you can have for a test.

Ideally one strives for running the maximum number of tests possible given
the system resources available, but a release is also time constrained. To
test a kernel to verify no regressions have occurred one is then also
constrained by the amount of time it takes to make a new kernel release.

Using the [PHB Crystall Ball](http://phb-crystal-ball.org/) we know that
based on the last 65 kernel releases we have an an average development time of
67 days, so a little over two months. The maximum possible number of
regression tests to run for a kernel release then is bound by how many
possible tests can run in about two months then. This is test suite specific.

## Confidence in a baseline

A baseline represents the known failures of a test suite in a release.
Since failure rates for some tests may be low, for instance the 1/600,
the higher number of tests we run a test suite, the higher the confidence
we have for a baseline. If your test bed is not running blktests block/009
over 600 times you likely would not have noticed the issue with block/009.

## Defining a Steady state testing goal for Linux upstream

Part of our test automation goals is to send a report out once a failure has
been found. But since we are also time-bound, we cannot test forever and
so therefore should also strive to send a report once a positive milestone
has been achieved.

We borrow the "steady state" term used for IO performance stabilization
to define reaching a positive test goal. We define a steady state test goal
as the the number times we wish to run a full test suite any without failure,
after which we optionally send an email report.

A steady state testing goal is bounded by the minimum amount of time it takes
to run a full test suite once, and by the maximum number of times a test suite
can run before a new release. Reaching steady state goals can be cumulative
in the sense that if two steady state goals are achieved on different systems
before the release of a kernel, the confidence in a baseline is raised by the
sum of the number of tests each steady state test goal achieved. So for
instance, if we successfully ran a steady state test goal of 100 three times
for fstests on btrfs on three separate systems, our confidence in that kernel
is such that we are at least covering failures which may have a failure rate
of about 1/300.

Using a lower steady state goal means you will just get more successful
reports for a release in lower amount of time. Defining a steady state goal
for a test suite is subsystem / test-suite specific.

## Steady state test goal for ftsests

Experience with fstests on kdevops shows that on average it takes about 5 days
to run 100 fstest tests, regardless of the filesytem we support, whether that
is for btrfs, xfs or ext4. We want to fix an issue before a kernel is released
and since achieving multiple steady state test goals are commulative, getting
a report about once a week for failures seems sensible. We therefore currently
recommend a steady state goal of 100 for fstests, and this would represent
running fstests successfully on one system for one filesystem 100 times. The
actual confidence in this baseline ends up being the cumulative number of times
we can accomplish this steady state over a slew of dedicated kernel-ci systems.

## Steady state test goal for blktests

About 100 test can complete with blktests in about 1 day, and so the steady
state test goal for blktests is currently set to 100. If we wanted to match
the timing with fstests we would use a steady state of 500, so that it also
takes 5 days to achieve steady state. We currently ended up deciding to
recommend to use a steady state goal of 100 instead of 500 for blktets since we
can have new linux-next release as often as once a day even though a full kernel
is released about every two months. Lowering the steady state in this case
allows us to try to do an upgrade to the latest KOTD more regularly, and
therefore spot regressions more easily on the block layer. This of course
however means getting reports daily about results though.

## Updating a kernel on the kernel-ci loop

Continous integration means we should be testing continously test. There are
different ways to do this. One way is to for example target a set of tests
based on codepaths modified. Another is trigger all tests based on any new
kernel released.

To start off a kernel-ci system can start by running tests continously and
update the kernel after each steady state goal is reached. This means that if
no new kernel is released by the time we achieve our steady state test goal,
we simply will augment the confidence in our baseline for the last kernel
tested.

## Steady state aggregate test goals

To help increase confidence in our baseline we can increase the amount of
systems available to run the same tests. Our confidence in our baseline then
can be inreased by adding more systems to our test infrastructure. So for
instance, one kernel-ci system may be running fstests for btrfs with a steady
state goal of 100. Having two systems running the same test with the same
steady state goal of 100 means that if the tests in these two systems are
successful and achieve steady state, the confidence in our baseline would
increase to 200 tests, not 100 over the same period of time it took to run
kernel-ci 100 tests, not 200. Over time, as we increase system capacity to our
kernel-ci system, so will our confidence in our baseline.

Below is a diagram which provides an example of how confidence in a kernel
baseline can grow over time as more systems are added a kernel-ci system. We
provide an example example of how to visualize possible evolution of confidence
in a baseline as more systems get added to a kernel-ci system, this example
diagram does not represent reality of any current kernel-ci setup. The number
on the y axis represents the amount of times fstests would have run successfully
against the baseline of each kernel, that is there is confidence to that degree
that the baseline represents all known current fstests failures, and could in
theory capture errors with failure rates up that that number.

![kernel-ci-steady-state-chart](/images/kernel-ci-chart.png)
