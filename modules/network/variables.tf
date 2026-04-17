variable "availability_domain" {
  description = "Availability domain for the subnet"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.2.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "ssh_allowed_source_cidr" {
  description = "Source CIDR allowed for ingress rules"
  type        = string
}

variable "tcp_wireguard_port" {
  description = "TCP port for WireGuard web UI"
  type        = number
}

variable "udp_wireguard_port" {
  description = "UDP port for WireGuard VPN"
  type        = number
}
