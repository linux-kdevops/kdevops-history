terraform {
	required_providers {
		template = {
		  source = "hashicorp/template"
		  # any non-beta version >= 2.1.0 and < 2.2, e.g. 2.1.2
		  version = "~>2.1"
		}
		aws = {
			source = "hashicorp/aws"
			version = "~>3.0"
		}
		null = {
			source = "hashicorp/null"
			version = "~>2.1"
		}
	}
}

provider "aws" {
	shared_credentials_file = var.aws_shared_credentials_file
	region                  = var.aws_region
	profile                 = var.aws_profile
}
