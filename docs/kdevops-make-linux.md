# Booting into a configured version of Linux

As an example of a target workflow, if you decided you want to enable the
workflow of Linux kernel development, to get the configured version of Linux on
the systems we just brought up, all you have to run is:

```bash
make linux
```

Immediately after this you should be able to ssh into either system, and `uname
-r` should disply the kernel you configured.
