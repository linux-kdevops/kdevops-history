## Targetting tests based on commit IDs or branches

We are evaluating adding support to run tests based on commit IDs or branches.
The way this will work is we will add support to kdevops to add different types
of test triggers, the first one being a code repository trigger. For example
if you have your own git repository and your own hardware to run tests you
might want to have something which always scrapes your git tree for updates
and if it detects an update, then run a test for you. A better way though
would be to only run tests if you had code changes affecting a subsystem.

And so you can have target filters set that so when code detected on the filter
is detected a build of that target kernel is generted and you run the respective
test, if a kernel configuration on kdevops exists for it.

To support this we'll have to come up with a way to compare the delta of code
changes on a kernel compared to the last state and infer required tests based
on a computed code delta from a target commit ID / branch. These inferences
would be test trigger specific, and so we refer to these tests by being based
on "trigger code inferences".

Support for this has yet to be written.
