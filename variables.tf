variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API signing key"
  type        = string
}

variable "private_key" {
  description = "Private key for OCI API authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for resource placement"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "shape" {
  description = "Compute instance shape"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "source_image_id" {
  description = "OCID of the source image for the compute instance"
  type        = string
}

variable "display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "docker-instance-terraform"
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
  description = "Source CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tcp_wireguard_port" {
  description = "TCP port for WireGuard web UI"
  type        = number
  default     = 51821
}

variable "udp_wireguard_port" {
  description = "UDP port for WireGuard VPN"
  type        = number
  default     = 51820
}
