provider "oci" {
  tenancy_ocid			= var.oci_tenancy_ocid
  user_ocid			= var.oci_user_ocid
  private_key_path		= var.oci_user_private_key_path
  fingerprint			= var.oci_user_fingerprint
  region			= var.oci_region
}
