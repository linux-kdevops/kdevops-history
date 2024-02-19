Constructing Node XML Files
===========================

Here are some basic recipes for constructing a guestfs_nnnn.j2.xml
file. This will be necessary only when bringing up a previously
unsupported guest ISA for use as a target guest.

There are already a few guestfs_nnnn.j2.xml files in this directory
to review for guidance.

Requirements
------------

These recipes assume you have already installed the virt-* tools
on your host.

Build a virtual machine image
-----------------------------

Use virt-builder to download an build a sample disk image for the
new guest. The following example builds a guest image with the same
ISA as the host.

  $ virt-builder fedora-38 --arch `uname -m` --size 20G --format raw

Provision a virtual machine
---------------------------

Use virt-install to start up a guest on the disk image you built.

  $ virt-install --disk path=./fedora-38.img --osinfo detect=on,require=off \
        --install no_install=yes --memory=8000

Extract node XML
----------------

Extract the guest's machine description into a file.

  $ virsh dumpxml xxx > guestfs_nnnn.xml
  $ virsh destroy xxx


Hand-edit XML
-------------

kdevops wants a jinja2 file that can be used to substitute configured
values into the XML. So:

  $ cp guestfs_nnnn.xml guestfs_nnnn.j2.xml
  $ edit guestfs_q35.j2.xml guestfs_nnnn.j2.xml

Find instances of "{{" and copy those lines, as appropriate, to the
new XML file.

Test the new file with "make && make bringup". Adjust the .j2.xml
file as needed.

When you are satisfied with guestfs_nnnn.j2.xml, delete guestfs_nnnn.xml,
then commit the guestfs_nnnn.j2.xml file to the kdevops repo.


License
-------

copyleft-next-0.3.1
