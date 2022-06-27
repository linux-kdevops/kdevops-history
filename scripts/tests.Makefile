# SPDX-License-Identifier: copyleft-next-0.3.1

# Collection of sanity tests to run for kdevops.

# You can implement python-tests by doing whatever you want with the tests
# target on each of these directories. These will run with a travis setup for
# python 3.8.
KDEVOPS_PYTHON_TESTS :=
KDEVOPS_PYTHON_TESTS += playbooks/roles/update_ssh_config_vagrant/update_ssh_config/

KDEVOPS_TEST_TYPES :=
KDEVOPS_TEST_TYPES += python-tests

python-tests:
	@for LOCAL_KDEVOPS_TEST in $(KDEVOPS_PYTHON_TESTS); do	\
		make -C $$LOCAL_KDEVOPS_TEST $@;		\
	done
PHONY += python-tests

tests:
	@for TEST_TYPE in $(KDEVOPS_TEST_TYPES); do             \
		make $$TEST_TYPE                                 ;\
	done
PHONY += tests
