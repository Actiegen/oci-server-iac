resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = "iac-network"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  display_name   = "iac-internet-gateway"
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "iac-network-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

resource "oci_core_subnet" "subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.subnet_cidr_block
  display_name               = "iac-server-subnet"
  availability_domain        = var.availability_domain
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = [oci_core_security_list.security_list.id]
  prohibit_public_ip_on_vnic = false
  depends_on                 = [oci_core_security_list.security_list]
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "allow-ssh-and-wireguard"

  # SSH — restricted to allowed source CIDR
  ingress_security_rules {
    protocol  = "6"
    source    = var.ssh_allowed_source_cidr
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # WireGuard VPN (UDP) — restricted to allowed source CIDR
  ingress_security_rules {
    protocol  = "17"
    source    = var.wg_allowed_source_cidr
    stateless = false

    udp_options {
      min = var.udp_wireguard_port
      max = var.udp_wireguard_port
    }
  }

  # WireGuard web UI (TCP) — only accessible from VPN subnet
  ingress_security_rules {
    protocol  = "6"
    source    = var.vcn_cidr_block
    stateless = false

    tcp_options {
      min = var.tcp_wireguard_port
      max = var.tcp_wireguard_port
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
