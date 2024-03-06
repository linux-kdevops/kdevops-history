# kdevops ltp suite

kdevops can run the ltp suite against a target kernel.

Run `make menuconfig` and select:

  Target workflows -> Dedicated target Linux test workflow -> ltp

Then configure the test parameters by going to:

  Target workflows -> Configure and run the ltp suite

This menu permits you to select the tests you would like to run and
the location of the repo that contains the version of git you want
to use for the test.

Then, run:

  * `make`
  * `make bringup`
  * `make ltp`
  * `make ltp-baseline`

Because the full ltp suite takes a long time to run, only a few
select file system-related tests are currently available. Additional
tests can be added to configuration menu via a code change. See:

  workflows/ltp/{Kconfig,Makefile}

and

  playbooks/roles/ltp/tasks/main.yml

for further details.
