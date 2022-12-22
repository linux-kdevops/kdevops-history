# Running kdevops for the first time

You shouldn't need much except what is listed on our requirements page.
However, if you are going to be using virtualization solutions or a cloud
solution (which will require terraform) you likely want to set up libvirt
properly or have us try to install terraform for you. We can help you do this.

To help with this we have an option on kconfig which you should enable if it is
your first time running kdevops, the prompt is for CONFIG_KDEVOPS_FIRST_RUN:

```
"Is this your first time running kdevops on this system?"
```

This will enable a set of sensible defaults to help with your first run. The
requirements will be installed for you when you call 'make', after
'make menuconfig'.

The way to use this 'first run' feature is to just enable the option, and
keep running `make` until it stops telling you to fix things. The first run
stuff verifies and ensures your user can bring up a virtualization guest as a
regular user without needing root, *if* you've enabled local virtualization
technologies. This is typically done by having your username be part of a few
special groups, depending on your Linux distribution. Other than that, the
other amount of work the `first run` stuff does is nags / complains are about
disabling apparmor / selinux, and maybe needing to reboot.

You should just disable the `CONFIG_KDEVOPS_FIRST_RUN` once kdevops stops
complaining about things, and then just run `make mrproper` and never, *ever*
enable it again. The reason you want to get to disable `CONFIG_KDEVOPS_FIRST_RUN`
is that leaving the enabled does a bit of sanity checks which are not needed
after your first run, and simply slow down your user experience.

If you want to set up a git mirror for Linux for personal use read
[kdevops mirror support](docs/kdevops-mirror.md). You may want to set up this
mirror if you are going to deploy multiple instances of kdevops on a same
system or network. If you are using a cloud environment you could still use
kdevops to set up a mirror but you'd run kdevops on an already instantiated
node on the cloud. kdevops could even bring those nodes up for you, but
setting this up for the cloud is a bit beyond the scope of this guide.

So let's re-iterate a few goals of the first run stuff:

  * Ensuring your user can run libvirt commands as a regular user withou
    a password
  * Disabling selinux / apparmor
  * Optionally install a git mirror for a few git trees you may use often

Disable `CONFIG_KDEVOPS_FIRST_RUN` after you have verified you can kdevops
works to bring up systems for you.
