resource "oci_core_instance" "compute_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    assign_ipv6ip    = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  source_details {
    source_type             = "image"
    source_id               = var.source_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  display_name = var.display_name
}
