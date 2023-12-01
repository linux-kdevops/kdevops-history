# kdevops git regression suite

kdevops can run the git tool's internal regression suite against
a target file system.

Run `make menuconfig` and select:

  Target workflows -> Dedicated target Linux test workflow ->gitr

Then configure the test parameters by going to:

  Target workflows -> Configure and run the git regression suite

Choose the file system type to test and the location of the repo
that contains the version of git you want to use for the test.

Then, run:

  * `make`
  * `make bringup`
  * `make gitr`
  * `make gitr-baseline`
