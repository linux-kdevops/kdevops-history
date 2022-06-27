all: python-tests
PHONY += all

python-tests: test flake8
PHONY += python-tests

test:
	python3 -m unittest discover -v
PHONY += test

flake8:
	flake8 --statistics
PHONY += flake8

.PHONY: $(PHONY)
