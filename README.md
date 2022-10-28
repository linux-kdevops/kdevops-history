Simple Linux mirror systemd unit and timer files
================================================

Some folks need to use rsync for mirroring, but if that is too much, you can
just use git clones and systemd service/timer files to update the git trees
based on Torvald's tree.

  * Requires *at least* ~20 GiB today for all 3 trees
  * Uses --reference on torvald's tree to save space
  * It will update linux.git every 10 minutes after it last ran
  * It will update linux-stable.git every 2 hours after it last ran
  * It will update linux-next.git every 6 hours after it last ran

To run a daemon just run something like this in a screen session:

```bash
git daemon --verbose --export-all /mirror
```
