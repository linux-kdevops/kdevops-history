# kdevops Linux kernel mirror support

Be sure to read [kdevops first run](docs/kdevops-first-run.md) before this
document.

Part of doing Linux kernel development is git cloning Linux or some
other trees, building, installing, and then running some things. The
effort to git clone can be quite slow, specially if you are working
with linux-next or building QEMU. And if you are using kdevops on a pretty
large system or set of systems that could benefit from a git mirror, kdevops
supports the ability to setup and git protocol mirror (git://) and start
mirroring any git tree we want.

Mirroring support is completely optional and is disabled by default.
If you however want to *enable* support for mirroring, all you want to
do is:

```bash
mkdir /mirror/
```

Then on a new clone of kdevops enable on `make menuconfig the option
`CONFIG_KDEVOPS_FIRST_RUN`. That will pick up that you have the directory
/mirror/ created and enable by default `CONFIG_INSTALL_LOCAL_LINUX_MIRROR`.
Just exit after that from `make menuconfig` and run `make`. Be sure to
read the other documentation about the `CONFIG_KDEVOPS_FIRST_RUN`.

*After* your first run, once you start to disable `CONFIG_KDEVOPS_FIRST_RUN`
on future runs, *if* you have /mirror/ then kdevops will assume you want
to *use* the mirror, so `CONFIG_USE_LOCAL_LINUX_MIRROR`. When this is
enabled the default options for using the mirror under /mirror/ will be
used or the git protocol if the node that will use the mirror is a guest.

If you don't have a /mirror/ directory kconfig assumes by default you don't
want to deal with this stuff.

If you want to set up a mirror for the first time just create that
directory, and ensure your user has write access to it, and there is
plenty of space there to clone some large trees. If you don't have
the /mirror/ directory created you can still setup your system to do
mirroring using `make menuconfig` and enabling the kconfig option
`CONFIG_INSTALL_LOCAL_LINUX_MIRROR`.

The following git trees are currently mirrored:

  * QEMU main tree (qemu-project/qemu)
  * The linux-next integration testing tree from Linux Next Group
  (next/linux-next)
  * The Linux kernel source tree from Linus Torvalds (torvalds/linux)
  * The Linux kernel stable tree from the Stable Group (stable/linux)
  * The Linux kernel mcgrof's tree (mcgrof/linux-next)

Root is only used to install the systemd socket activation git daemon.
Socket activation just means the service will not run or consume memory
if no one has come knocking on the git port. systemd unit / timer files
are used to deploy mirroring support as a regular user for each git tree
we support. kdevops supports this under the directory
[linux-mirror-systemd](playbooks/roles/linux-mirror/linux-mirror-systemd/)

The following timers are used for mirroring (we don't yet support
variability for this):

 * qemu-project/qemu: every 10 minutes
 * next/linux-next: every 6 hours
 * torvalds/linux: 10 minutes
 * stable/linux: every 2 hours
 * mcgrof/linux-next: every 6 hours

## Manual debugging

Although kdevops takes care of mirroring support for you, if you want to
debug things you can run the current make targets manually:

```bash
make -C playbooks/roles/linux-mirror/linux-mirror-systemd/ mirror
make -C playbooks/roles/linux-mirror/linux-mirror-systemd/ install
```

## git mirror on the cloud

Yes you can use kdevops to bring up nodes on the cloud and then install
a git mirror on that node with kdevops. But doing that would require you
use kdevops in a two separate step phase right now:

  * Use kdevops on a host to instantiate your cloud nodes
  * Manually git clone kdevops on the cloud node and install the git
    mirror setup. You may then want to also test other nodes on the
    network can git clone to it.

## TODO

Mirroring supports needs to be enhanced to support variability. Although
we stuff the code into an Ansible directory, we don't in practice use it
as such yet. The 'mirror' and 'install' targets need to be converted to
Ansible role tasks. Then we can easily allow for variability.

But in the cases that most folks are OK with a mirror on /mirror/ this
should suffice.

We *may* want to turn down the timers down a notch to not DOS git servers.
