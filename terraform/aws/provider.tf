# Describes the provider we are going to use. This will automatically
# phone home to HashiCorp to download the latest azure plugins being
# described here.

provider "template" {
  # any non-beta version >= 2.1.0 and < 2.2, e.g. 2.1.2
  version = "~>2.1"
}

provider "aws" {
  version                 = "~>2.24"
  shared_credentials_file = var.aws_shared_credentials_file
  region                  = var.aws_region
  profile                 = var.aws_profile
}

