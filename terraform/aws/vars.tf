# You may want to enable this if for example your aws subscription is
# the free trial. As of May 2019 you get only XXX.
#
# We set this to true for now to ensure a good experience from users
# of this fs tests aws provider, assuming they're also using the
# aws free trial account. Set this to "no" on your terraform.tfvars file
# to override.
variable "limit_boxes" {
  description = "Limit the number of nodes created"
  default     = "no"
}

# 4 is be the default for number of boxen allowed on the azure demo account
variable "limit_num_boxes" {
  description = "The max number of boxes we're allowing terraform to create for us"
  default     = "2"
}

# This is for North california, if you want another one:
# https://docs.aws.amazon.com/general/latest/gr/rande.html
variable "aws_region" {
  description = "Your preferred AWS region"
  default     = "us-west-1"
}

# I got mine by an error output after using the same region as above
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
# https://gist.github.com/neilstuartcraig/0ccefcf0887f29b7f240
variable "aws_availability_region" {
  description = "Your preferred AWS region"
  default     = "us-west-1b"
}

variable "ssh_keyname" {
  description = "The name of your ssh key, this is just the name displayed and used on aws in the backend"
  default     = "kdevops_aws_key"
}

variable "ssh_pubkey_data" {
  description = "The ssh public key data"

  # for instance it coudl be "ssh-rsa AAetcccc"
  default = ""
}

# AMI updates for debian:
# https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
#
# If you want to choose another distro:
# https://letslearndevops.com/2018/08/23/terraform-get-latest-centos-ami/
# To get filter values you can first setup aws cli:
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration
# Get your image ami id, for debian 9 amd64 on the us-west1 this is
# ami-0adbaf2e0ce044437 so you can run:
#
# aws ec2 describe-images --image-ids ami-0adbaf2e0ce044437
# For details:
#
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
#
# Using this filter glob lets us get the latest ami for this owner / release.
variable "aws_name_search" {
  description = "Youre AWS AMI search name filter"
  default     = "debian-stretch-hvm-x86_64-*"
}

# This has to match your preferred image filter above too.
variable "aws_virt_type" {
  description = "Youre AWS preferred virtualization type"
  default     = "hvm"
}

variable "aws_ami_owner" {
  description = "Youre AWS AMI image owner"

  # Debian
  default = "379101102735"
}

# https://aws.amazon.com/ec2/instance-types/
# Free trial limits you to 750 hours of only t2.micro
variable "aws_instance_type" {
  description = "Your AWS instance type"
  default     = "t2.micro"
}

variable "aws_enable_ebs" {
  description = "Whether or not to enable EBS"
  default     = "no"
}

variable "aws_ebs_num_volumes_per_instance" {
  description = "Number of EBS volumes to create per instance"
  default     = "1"
}

# Sigh.. These are required! And oh my, what a mess this is...
#
# Notes: on a t2.micro with 2 hosts we should use /dev/sdh /dev/sdh in this
# this list, but note that this will actually map to /dev/xvdh on both hosts.
# And if you don't do that, and you use /dev/sdh, dev/sdi here then the
# first host will get /dev/xvdh and the second one /dev/xvdi
#
# The first aws instance type to support nvme is the c5d.large with just one
# nvme drive. But subsequent EBS drivers get pegged as nvme as well. *And*
# even if you want to use nvme, you must use /dev/sdh /dev/sdh here...
#
# To avoid this mess just pick a damn instance name with the drive setup
# you need for development, if you can afford it.
variable "aws_ebs_device_names" {
  description = "The EBS device names to use"
  type        = list(string)
  default     = ["/dev/sdh", "/dev/sdh"]
}

# The t2.micro comes with 8 GiB of storage.
# For more storage we need to use EBS.
# AWS Free Tier includes 30GB of Storage, 2 million I/Os, and 1GB of snapshot
# storage with Amazon Elastic Block Store (EBS).
#
# Note: if using two hosts and you specify here 30 and 150, this means the
# first EBS will be pegged on to the first host with 30 GiB, and the second
# EBS to the second host with 150 GiB in size.
variable "aws_ebs_volume_sizes" {
  type        = list(string)
  description = "Size in GiB for each of the volumes"
  default     = ["150", "160"]
}

# We had to use this as aws terraform provider doesn't have a way to set
# the hostname. local-exec works too, but this is what we went with.
variable "user_data_enabled" {
  description = "Do you want to enable cloud-init user data processing?"
  default     = "yes"
}

variable "user_data_log_dir" {
  description = "Where on the node you want user_data processing logs to go"
  default     = "/var/log/user_data"
}

# Disable for non-systemd systems, you'll want to implement something that
# does all what systemd does for us then if you still want your hostname
# changed.
variable "user_data_admin_enable_hostnamectl" {
  description = "Should we use hostnamectl to change the target hostname?"
  default     = "yes"
}

# kdevops does want us to have the hostname there, yes... so this is required.
# I forget which tests requires this.
variable "user_data_admin_enable_host_file" {
  description = "Should /etc/hosts also be appended with the new hostname with the localhost address?"
  default     = "yes"
}

variable "aws_shared_credentials_file" {
  description = "Shared aws credentials file"
  default     = "~/.aws/credentials"
}

variable "aws_profile" {
  description = "Shared aws credentials file"
  default     = "default"
}
