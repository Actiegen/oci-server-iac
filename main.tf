provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}
module "compute_instance" {
  source              = "./modules/compute-instance"
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.shape
  ssh_public_key      = var.ssh_public_key
  source_image_id     = var.source_image_id
  subnet_id           = module.network.subnet_id
  display_name        = var.display_name
  depends_on          = [module.network]
}

module "network" {
  source                  = "./modules/network"
  availability_domain     = var.availability_domain
  compartment_id          = var.compartment_id
  ssh_allowed_source_cidr = "0.0.0.0/0"
  tcp_wireguard_port      = "51821"
  udp_wireguard_port      = "51820"
}
