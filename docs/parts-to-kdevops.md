# Parts to kdevops

There are five parts to kdevops:

0. Configuring kdevops
1. Installing ansible roles required
2. Optional provisioning required for virtual hosts / cloud environment
3. Provisioning your requirements
4. Running whatever workflow you want

We configure kdevops using the Linux modeling variability language, kconfig.
Using kconfig streamlines the other steps for you, and rely on `Makefile`
target to bundle the work under one command.

Ansible is used to get all the required ansible roles.

Vagrant or terraform can then optionally be used to provision hosts. You don't
need to use vagrant or terraform if you are using baremetal hosts.

Vagrant makes use of three ansible roles to let you use libvirt as a regular
user, update your `~/.ssh/config`, update the systems with basic development
preference files, things like your `.gitconfig` or bashrc hacks, or typical
packages which you most likely need on any system where you do Linux kernel
development. This last part is handled by the `devconfig` ansible role. Since
your `~/.ssh/config` is updated you can then run further ansible roles manually
when using vagrant.

You would use terraform if instead you want to provision hosts on the cloud, it
updates your `~/.ssh/config` directly without ansible. Setting up hosts with
terraform can take time, but what we care most about is *when* hosts are
finally ready and accessible. Unfortunately some cloud providers can be buggy
and can lie to you about them being ready and accessible. If we were to believe
these buggy cloud providers the last provisioning step of running ansible to
update your `~/.ssh/config` and the `devconfig` ansible role would time out.
Because of these buggy cloud providers the last step to run ansible to
update your `~/.ssh/config` and run the `devconfig` ansible role is
expected to be done manually. One day we expect this to not be an issue.

After provisioning you want to get Linux, configure it, build it, install it
and reboot into it. This is handled by the `bootlinux` ansible role. This is
a bare minimum example of "Running whatever you want", however there are
more eleborate examples, which take this further.

