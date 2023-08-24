# How is the kdevops KDEVOPS_EXTRA_VARS extra_vars.yaml file is generated

kdevops is highly dynamic in nature, to the extent we even support host
specific PCIe passthrough support. To do that we must allow a highly dynamic
ansible extra vars file we use to allow us to override all possible ansible
role default variables. In the future we will extend kconfig to generate
both a `.config` file and an `extra_vars.yaml` but for now we have Makefiles
for each component we support which reads the input .config values and then
decides which ones should be converted as part of the final `extra_vars.yaml`
file.

## KDEVOPS_EXTRA_VARS

The default value for KDEVOPS_EXTRA_VARS is extra_vars.yaml, you can however
override this. All ansible roles include this file though so care must be
taken if you do override it.

## ANSIBLE_EXTRA_ARGS

The top level Makefile initializes `ANSIBLE_EXTRA_ARGS` as an empty string.
We use Makefile variable appends, as in the example below to extend new
variables to be later used in the target output `extra_vars.yaml` file:

```
ANSIBLE_EXTRA_ARGS += kdevops_version='$(PROJECTRELEASE)'
```

In this case the Makefile `$PROJECTRELEASE` is used to define the ansible
variable `kdevops_version` as a string.

## Workflow specific extra vars

Instead of only using `ANSIBLE_EXTRA_ARGS` everywhere, we allow easy grep'ing
for variables for each workflow by having each workflow to define their own
set of variables. So for example, the top level workflow `workflows/Makefile`
has:

```
WORKFLOW_ARGS           :=
...
BOOTLINUX_ARGS  :=
ifeq (y,$(CONFIG_BOOTLINUX))
WORKFLOW_ARGS += kdevops_bootlinux='True'
include workflows/linux/Makefile
endif # CONFIG_BOOTLINUX == y
```

The `bootlinux` workflow is the `shared workflow` which let's you get, build
compile and install Linux from different git trees. And so it also defines
its own `BOOTLINUX_ARGS`.

## BOOTLINUX_ARGS

On the `workflows/linux/Makefile` we can see how Kconfig variables are
processed to remove the quotes (`"`) and then its own set of target
variables it wants on extra_vars.yaml by appending to `BOOTLINUX_ARGS`.
This make it easy to just `git grep BOOTLINUX_ARGS` to see what is defined.

```
TREE_URL:=$(subst ",,$(CONFIG_BOOTLINUX_TREE))
TREE_NAME:=$(notdir $(TREE_URL))
TREE_NAME:=$(subst .git,,$(TREE_NAME))
TREE_TAG:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_TAG))
TREE_LOCALVERSION:=$(subst ",,$(CONFIG_BOOTLINUX_TREE_LOCALVERSION))
TREE_SHALLOW_DEPTH:=$(subst ",,$(CONFIG_BOOTLINUX_SHALLOW_CLONE_DEPTH))

TREE_CONFIG:=config-$(TREE_TAG)
ifeq (y,$(CONFIG_BOOTLINUX_PURE_IOMAP))
TREE_CONFIG:=config-$(TREE_TAG)-pure-iomap
endif

# Describes the Linux clone
BOOTLINUX_ARGS  += target_linux_git=$(TREE_URL)
BOOTLINUX_ARGS  += target_linux_tree=$(TREE_NAME)
BOOTLINUX_ARGS  += target_linux_tag=$(TREE_TAG)
BOOTLINUX_ARGS  += target_linux_config=$(TREE_CONFIG)
BOOTLINUX_ARGS  += target_linux_localversion=$(TREE_LOCALVERSION)
```

## Complex Kconfig variables ANSIBLE_EXTRA_ARGS_SEPARATED

Some Kconfig values are a bit more complex and need a bit more processing.
To learn more about them `git grep ANSIBLE_EXTRA_ARGS_SEPARATED`.

## Supporting more complex things EXTRA_VAR_INPUTS_LAST

To support even more things such as the variables used for PCIe passthrough
`git grep EXTRA_VAR_INPUTS_LAST`. We essentially just post process this after
the file is generated with the first part. Then we just append to it.

## Kconfig yaml output support

We should be able to simplify all this by just having Kconfig upstream
support an optional yaml output file. This would remove all
the above requirements for silly simple variables, and we'd just have to
make sure we parity with the variable names and kconfig options used. That
will obviously grow the `extra_vars.yaml` file without much need though,
so one option to fix that and not go crazy with how many variables we
output is to have an option in Kconfig below a Kconfig symbol which let's
us specify which ones are targetted for yaml output. This might bring
complexities but if the size of the yaml output is of cooncern it is one
way to go about this. If the length of the yaml file is of no concern then
this feature is not needed.
