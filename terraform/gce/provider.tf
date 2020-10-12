provider "google" {
  version = "~>v3.32.0"

  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}
