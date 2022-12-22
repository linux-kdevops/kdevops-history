# Running make bringup on kdevops

Bringup nodes only makes sense if you are requiring help from kdevops to do
so. That is, for cloud solutions or for virtualized solutions. If you are using
bare metal you can skip this step unless you want to run the devconfig playbook.

To get your systems up and running and accessible directly via ssh, just do:

```bash
make bringup
```

At this point you should be able to run:

  * `ssh kdevops`

The host name is set up through the kconfig symbol `CONFIG_KDEVOPS_HOSTS_PREFIX`.
There are sensible defaults set up for this depending on your virtualization or
cloud environment, but you should always be aware of what this is going to be
set up with. To verify you can just:

```bash
cat hosts
```

Or just run:

```bash
grep CONFIG_KDEVOPS_HOSTS_PREFIX .config
```

## The devconfig playbook

The devconfig playbook is an ansible playbook which is run after your
nodes are brought up. This installs your .gitconfig, prefered bash hack sripts,
.vimrc, etc. But it also installs a set of packages you likely want installed
on most systems. This is all configurable.
