resource "oci_core_vcn" "vcn" {
  cidr_block     = "10.2.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "iac-network"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  display_name   = "iac-internet-gateway"
  vcn_id         = oci_core_vcn.vcn.id
  enabled     = true
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
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.vcn.id
  cidr_block          = "10.2.1.0/24"
  display_name        = "iac-server-subnet"
  availability_domain = var.availability_domain
  route_table_id      = oci_core_route_table.route_table.id
  security_list_ids   = [oci_core_security_list.ssh_security_list.id]
  prohibit_public_ip_on_vnic = false
  depends_on = [ oci_core_security_list.ssh_security_list ]
}

resource "oci_core_security_list" "ssh_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "allow-ssh-and-wireguard"

  ingress_security_rules {
    protocol = "6"
    source   = var.ssh_allowed_source_cidr

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.ssh_allowed_source_cidr

    tcp_options {
      min = var.tcp_wireguard_port
      max = var.tcp_wireguard_port
    }
  }

  ingress_security_rules {
    protocol = "17"
    source = var.ssh_allowed_source_cidr

    udp_options {
      min = var.udp_wireguard_port
      max = var.udp_wireguard_port
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

