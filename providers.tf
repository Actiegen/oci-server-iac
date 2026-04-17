terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.7.0"
    }
  }

  backend "oci" {
    bucket    = "terraform-state"
    namespace = "grymh3ejznub"
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}
