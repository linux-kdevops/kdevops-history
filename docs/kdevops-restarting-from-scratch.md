# Re-using kdevops to destroy and spawn new guests

If you want to re-use an existing kdevops tree to destroy some
old guests and spawn some new ones you would use:

```
make destroy
make mrproper
```

Be mindful of the space used in the libvirt storage pool if you are
using libvirt. Verify that the above gets rid of all the crap the
guest used to use. Kdevops *should* remove all the junk for you, but
it is always good to double check.
