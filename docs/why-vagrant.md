# Why vagrant is used for virtualization

There are a few reasons why kdevops has embraced vagrant. Below we go through
each of them.

## What is a vagrant box anyway?

First let's understand what a vagrant box is. A vagrant box is essentially a
tarball (gzip, xc are both supported) with a qcow2 image and a small metadata
file explaining how large the drive for the guest is.

## Reducing bring up speed

Hackers just want to get a guest up fast, slap a kernel on it as fast as
possible, and hope it comes up, and then run some tests or hack something up
on the kernel. The faster we can do this the better.

The typical approach to using guests is to install a guest using an ISO, and
that takes time. Another way is to just keep copies around of some qcow2 images
and just copy them over when you want to do something new. This can become a
bit of a managing nightmare if you are doing this manually though. Vagrant
abstracts this for you, and essentially does just that.

## Vagrant has sensible developer friendly settings

If you are installing a guest with an ISO, you likely will then start doing
a few custom things as a developer. The first thing most developers do is
add a sudoers for your username. A vagrant box already comes with these things
preset. Also, sensible defaults for the username and root password are set,
because we don't care about security when doing quick bringups for quick
development / testing.

Another example setup which vagrant takes care of is bringing up ssh and
letting you ssh to the guest right away. Below is a list of things vagrant
boxes already come set up with, so you as a developer don't have to do this:

  * 1) root/vagrant user password is vagrant
  * 2) vagrant user on /etc/sudeors does not need a password to gain root
  * 3) vagrant can create a random ssh key for each guest
  * 4) Deal with persistent net rules
  * 5) Ensure DHCP will work on the first network interface
  * 6) Ensure the console is allowed
  * 7) Try to use disk partitions by UUID on /etc/fstab
  * 8) grub disk setup with UUID

If you'd like to learn more about this read the
[making custom vagrant boxes documentation](docs/custom-vagrant-boxes.md)

## Supporting different virtualization technologies

There are different software solutions available which can take
advantage of your architecture's virtualization features and control
guests. Examples are libvirt, virtualbox. Vagrant abstracts the
virtualization solution used as a "provider" and each provider then
can support its own way to bring up guests.

## Supporting different Operating Systems

If we only supported libvirt it would mean you cannot use kdevops on Mac OS X.
OS X users can make user of virtualbox for kdevops.
