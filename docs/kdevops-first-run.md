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

You can safely disable this option after you've already run kdevops on a system
once successfully, ie, after your first successful 'make bringup'. In fact,
this does tons of checks which are not needed, so you should just disable this
after your first run for sure. Maybe in the future we will detect if you
already had a successful run if CONFIG_KDEVOPS_FIRST_RUN is set and then
just disable this after that.
