Qemu kernel configs
===================

These configs are provided to allow folks to build the same kernel as which
was used for the fstests testing with oscheck. The kernel config is a reduced
Debian distribution minimal config to only work with fstests. Details about
this is documented below.

# Methodology

Since the kernels have to be built often, we want to reduce the size of
the amount of options enabled. Se make use of the kernel's 'make locamodconfig'
for this purpose, which leaves enabled *only* the kernel configs you either
have enabled as `=y` and the respective options required to enable the same
modules as you have currently loaded. The module --> config search option
by localmodconfig is not 100% reliable since there is no currently relaible
mechanism to map modules to configs, and since module names can change, and you
can be on an older kernel. There are efforts to increase the reliability of
module mapping to config options [0], however such effort is not yet merged.
Despite these limitations, 'make localmodconfig' suffices well enough for our
purposes, you just need to ensure you start off with a kernel version which is
as new or close to the target kernel you want to test.

[0] https://lkml.kernel.org/r/CAB=NE6UfkNN5kES6QmkM-dVC=HzKsZEkevH+Y3beXhVb2gC5vg@mail.gmail.com

## Running a distro fstests first

Since fstests loads module you may not have enabled yet on a fresh boot you
should run a full set of tests from fstests prior to running
'make localmodconfig' using your distribution kernel config as base. This
will ensure that all required modules for fstests are loaded.

## pmem

pmem has not yet been enabled. This should be easy to fix.
