# Generic rule, you can be more specific in your own makefiles.
%.o: %.c *.h
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $<

# Capture directories on obj-y and remove their leading character
# We will use this to construct a subdir object target for each, and
# a respective clean target.
__subdir-y      := $(patsubst %/,%,$(filter %/, $(obj-y)))
subdir-y        += $(__subdir-y)
subdir-y       := $(sort $(subdir-y))

# Make a target rule for each subdir, so that we can later add to the obj-y
# target. The subdir-y-obs carries all subdirectory objects.
# If a subdir name dirname exists, we add dirname/dirname.o to the list of
# objects in subdir-y-objs
subdir-y-objs       := $(foreach t,$(subdir-y),$(addsuffix /$t.o,$(t)))

# Add a phony clean target, you'll need to add this as a dependency on the
# top level clean target.
clean-subdirs       := $(foreach t,$(subdir-y),$(addsuffix /.ignore-clean,$(subdir-y)))
PHONY += $(clean-subdirs)

# Remove all directories from obj-y
obj-y      := $(filter-out %/, $(obj-y))

# Add the directory objects now to obj-y
obj-y      := $(obj-y) $(subdir-y-objs)

# For each clean target add a clean rule.
$(clean-subdirs):
	$(MAKE) -C $(CURDIR)/$(patsubst %/.ignore-clean,%,$@) clean

# For each subdirectory object target add a respective build target
# using a default target, by using the directory name only.
$(subdir-y-objs):
	$(MAKE) -C $(dir $@)
