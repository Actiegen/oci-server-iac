variable "availability_domain" {
  description = "Availability domain for the instance"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "shape" {
  description = "Compute instance shape"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "source_image_id" {
  description = "OCID of the source image"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet to attach the instance to"
  type        = string
}

variable "display_name" {
  description = "Display name for the instance"
  type        = string
}
