module "compute_instance" {
  source             = "./modules/compute-instance"
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape
  subnet_id           = var.subnet_id
  ssh_public_key      = var.ssh_public_key
  source_image_id     = var.source_image_id
  display_name = var.display_name
}
