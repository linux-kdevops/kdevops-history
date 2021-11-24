# Motivations for kdevops's kernel-ci

There are different kernel-ci efforts out there. They serve a few purposes.
Our goal is to allow Linux developers and different Linux distributions to be
able to build different test baselines for different test suites for a kernel
release, and allow them to detect regressions when new changes are merged.
The kdevops kernel-ci effort can then be used to test kernel merge commits
prior to integration, so to ensure no regressions occur proactively on a
kernel release.

# kdevops kernel-ci requirements

The kdevops project has taken on its own kernel-ci effort given the requirements
we set out to meet and that upon review no existing project suited our needs.
Our requirements are:

  * We wan to be able to build tests on the fly on bare metal, virtualized
    guests, or cloud solutions. This gives us the flexibility to let developers
    and our test infrastructure pick any solution to run tests on, it also gives
    us the possibility to allow kernel-ci efforts to grow test capacity using
    different technologies.
  * We want to run tests and produce test results in a way that developers can
    easily relate to. No fancy dashboards are required, however they can be
    developed. If a regresssion occurs we want to be notified about it.
  * Initial target test requirements were to support testing fstests and
    blktests. More tests have been added with time. More tests for different
    subsystems are expected to be added and are welcomed.

# kdevops kernel-ci automation framework

Instead of inventing its own wheel to deal with management of guests, ansible
has been embraced for detailing how to codify required commands for each
target workflow. Adding Salt support in the future as an alternative for
management can surely be done, it would just be a matter of extending new
kconfig symbols. Using ansible was done first as that is what the author had
most experience with.

Each target test is considered a "workflow" under kdevops. Using ansible also
allows for distribution specific items to be split out and dealt with
separately. As it stands, support for OpenSUSE, SUSE, Debian, and Fedora are
provided for all supported workflows. If a new workflow is added, you don't
need to add support for all distributions, a kconfig "depends on" logic can
easily be used to ensure only support for the few distributions is expressed.
As it stands though, all currently supported workflows support all supported
distributions, and developers are highly encouraged to try to add support for
all of them as well, as the differences in support typically mostly deals with
package names, grub and the kernel, and that is already dealt with in existing
workflows.

Below is kdevops' kernel-ci recommended documentation reading before trying to
enable kdevops kernel-ci and using it.

  * [Reviewing existing kernel-ci efforts](docs/kernel-ci/review-existing-kernel-ci-efforts.md)
  * [Using kdevops as a git subtree in light of kernel-ci](docs/kernel-ci/kdevops-subtree-recommeded.md)
  * [Recommended methodology to a define kernel-ci host and guest architecture](docs/kernel-ci/recommendations-kernel-ci-architeture.md)
  * [A case for truncated files with loopback block devices](docs/testing-with-loopback.md)
  * [Seeing more issues with loopback / truncated files setup](docs/seeing-more-issues.md)
  * [kernel-ci guest requirements](docs/kernel-ci/kernel-ci-guest.md)
  * [kernel-ci host requirements](docs/kernel-ci/kernel-ci-host.md)
  * [kernel-ci host hypervisor tuning](docs/kernel-ci/kernel-ci-hypervisor-tuning.md)
  * [kernel-ci steady state goals](docs/kernel-ci/kernel-ci-steady-state-goal.md)
  * [Targetting tests based on commit IDs or branches](docs/kernel-ci/kernel-ci-test-trigger-code-inferences.md)
  * [Appreciating kernel-ci division of labor](docs/kernel-ci/kernel-ci-division-of-labor.md)
  * [Evaluating use of a digital ledger](docs/kernel-ci/kernel-ci-division-of-labor.adoc)
