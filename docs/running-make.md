# Running make

After you configuration you to just run:

```
make
```

If this is your first run and you enabled `CONFIG_KDEVOPS_FIRST_RUN` then
some more things will be done for you as documented in
[kdevops first run](docs/kdevops-first-run.md).

You should however disable `CONFIG_KDEVOPS_FIRST_RUN` after you first run.

Running `make` will do a few more things:

  * Reads you .config and based on this generate an equivalent yaml file to
    be used by ansible moving forward. The file is `extra_vars.yaml`. You
    can always just remove this file, and run `make extra_vars.yaml`
    if you want to regenerate the file.

  * Generates the top level ansible host file

  * If using virtualization it will generate the dynamic vagrant nodes
    file, `kdevops_nodes.yaml`.

