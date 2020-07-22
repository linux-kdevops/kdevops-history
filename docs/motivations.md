# Motivation behind kdevops

A tedious part about doing Linux kernel development or testing is ramping up
a set of systems for it. For instance, settings up a test bed for testing
Linux filesystems can often take weeks. kdevops was born with an initial goal
to reduce this amount of time to a couple of minutes. It turns out that
doing this correctly for baremetal, but also in a virtualization-neutral and
cloud-neutral way, is useful for many other things than just Linux filesystems
testing, and so kdevops was born to generalize bring up for Linux kernel
development and testing as fast as possible.

# Fork me

You can either fork this project to start your own kdevops project, or you can
rely on the bare bones `kdevops_install` ansible galaxy role to get going and
use this project as an example of how to use that ansible role.

