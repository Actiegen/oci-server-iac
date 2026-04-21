module "compute_instance" {
  source                  = "./modules/compute-instance"
  availability_domain     = var.availability_domain
  compartment_id          = var.compartment_id
  shape                   = var.shape
  ocpus                   = var.ocpus
  memory_in_gbs           = var.memory_in_gbs
  ssh_public_key          = var.ssh_public_key
  source_image_id         = var.source_image_id
  subnet_id               = module.network.subnet_id
  display_name            = var.display_name
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  depends_on              = [module.network]
}

module "network" {
  source                  = "./modules/network"
  availability_domain     = var.availability_domain
  compartment_id          = var.compartment_id
  vcn_cidr_block          = var.vcn_cidr_block
  subnet_cidr_block       = var.subnet_cidr_block
  ssh_allowed_source_cidr = var.ssh_allowed_source_cidr
  wg_allowed_source_cidr  = var.wg_allowed_source_cidr
  tcp_wireguard_port      = var.tcp_wireguard_port
  udp_wireguard_port      = var.udp_wireguard_port
}
