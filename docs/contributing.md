# Contributing to kdevops

We have a kdevops mailing list: kdevops@lists.linux.dev

# Avoid subscribing and use lei instead!

Really, subscribing is the thing of the 80's and 90's. The new easy way
is to just use lei.

```
lei q -I https://lore.kernel.org/all/ -o Mail/linux/kdevops \
       --threads --dedupe=mid \
      'l:kdevops.lists.linux.dev AND rt:1.year.ago..'

# To get new emails just run
lei up --all

# To read email:
mutt -f Mail/linux/kdevops/
```

# If you really want to subscribe ...

  * To subscribe send an email to kdevops+subscribe@lists.linux.dev
  * To unsubscribe send an email to kdevops+unsubscribe@lists.linux.dev

# The kdevops mailing list archive

[kdevops mailing list archive](https://lore.kernel.org/kdevops/)

# Posting patches

To post patches please use git format-patch and then git send-email.
Pull requests on the web are ignored.

# Commit log requirements

Commit logs should have a subject and something to describe on the
commit message, even if its a typo. And if you're going to fix one
typo, why not fix a few?

# Patch requirements

Please use the Signed-off-by tag, the meaning of which is defined in
[CONTRIBUTING](./CONTRIBUTING) file.

# kdevops developers

If you are contributing more than one patch and intend to contribute more
regularly we may just add you to the linux-kdevops group to allow you to
just commit and push to the shared tree. We never reset the tree.
