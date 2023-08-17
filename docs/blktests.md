# kdevops block layer testing support

kdevops has support testing Linux block layer testing using 
the blktests test suite. This documents support for that.

# kdevops blktests configuration

Other than using Kconfig to let you configure your bring up environment and
requirements kdevops also brings the options that blktests offers into Kconfig,
and so enables an easy way to configure you blktests test environment.

# kdevops blktests dedicated workflow

If you are going to mainly test with the block layer you really want to enable a
dedicated workflow (`CONFIG_KDEVOPS_WORKFLOW_DEDICATE_FSTESTS=y`) as that allows
kdevops to let you pick and choose the different target block layer configuration
options you can test. Some Linux distributions may have older kernels, for
instance, which may not have support for new features which cannot be tested.
kdevops uses Kconfig to allow developers to `select` which target block layer
configuration options are supported by a distro kernel or not. This avoids having
users testing incorrect or unsupported block layer configurations.

A dedicated workflow also let's us build target host nodes either for a cloud
deployment or a local virtualization setup which is built off of each target
supported block target we want to support and test.

# Target devices to use to test

# Seeing kdevops community fstests results

See [viewing kdevops archived results](docs/viewing-fstests-results.md) to see
how you can look at existing results file inside kdevops.
