# kdevops Linux selftests support

The Linux kernel has a set of sets under tools/testing/selftests which we
call "Kernel selftests". Read the [Linux kernel selftests documentation](https://www.kernel.org/doc/html/latest/dev-tools/kselftest.html).
Running selftests used to be fast back in the day when we only had a few
kernel selftests. But these days there are many kernel selftests. Part of
the beauty of Linux kernel selftests is that there are no rules -- you make
your rules. The only rules are at least expicitly mentioning a few targets
for Makefiles so that the overall selftests facility knows what target to
call to run some tests. Part of the complexity in selftests these days is
that due to the lack of rules, you may end up needing a bit of dependencies
installed on the target node you want to run the tests on. Kdevops will take
care of that for you, and so selftests support are added by each developer
which wants to help make this easier for users. Today there is support for
at least 3 selftests:

  * `make selftests`
  * `make selftests-baseline`

You can also run specific tests:

  * `make selftests-firmware`
  * `make selftests-kmod`
  * `make selftests-sysctl`

