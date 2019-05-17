# Describes the provider we are going to use. This will automatically
# phone home to HashiCorp to download the latest azure plugins being
# described here.

provider "template" {
  # any non-beta version >= 2.1.0 and < 2.2, e.g. 2.1.2
  version = "~>2.1"
}

provider "aws" {
  # any non-beta version >= 2.11.0 and < 2.12.0, e.g. 2.11.2
  version = "~>2.11"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
