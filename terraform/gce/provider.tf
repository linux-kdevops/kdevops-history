terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>4.27"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>2.1"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}
