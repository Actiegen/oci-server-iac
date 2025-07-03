terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "7.7.0"
    }
  }

  backend "oci" {
    bucket            = "terraform-state"
    namespace         = "grymh3ejznub"
  }
}
