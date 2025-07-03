terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "7.7.0"
    }
  }

  backend "oci" {
    # Required
    bucket            = var.bucket
    namespace         = var.namespace 
    tenancy_ocid      = var.tenancy_ocid 
    user_ocid         = var.user_ocid 
    fingerprint       = var.fingerprint 
    private_key_path  = var.private_key_path 
    region            = var.region 
    auth              = var.auth 
    config_file_profile = "DEFAULT"
  }
}
