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

If you are enabling this option you are highly encouraged first do a basic
test run with kdevops to ensure you can use it, and once everything is verified
you should just remove the nodes you created and start again from scratch
and disabe `CONFIG_KDEVOPS_FIRST_RUN`. The reason is that leaving the kconfig
option `CONFIG_KDEVOPS_FIRST_RUN` enabled does a bit of sanity checks which
are not needed after your first run.

So if you enable `CONFIG_KDEVOPS_FIRST_RUN` just enable the configuration
options you need for your provisioning if enabling virtualization or a cloud
solution and don't bother with the rest, run `make; make bringup` verify you
can get the system sup, ssh into the systems, ad then run `make destroy`.
A reboot may very likely be required if its your first run before running
`make bringup`. Things like these are checked for and it is why you very
likely need to reboot after you have modified your system:

  * Ensuring your user can run libvirt commands as a regular user withou
    a password
  * Disabling selinux / apparmor

Disable `CONFIG_KDEVOPS_FIRST_RUN` after you have verified you can kdevops
works to bring up systems for you.
