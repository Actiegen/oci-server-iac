output "instance_public_ip" {
  value = oci_core_instance.compute_instance.public_ip
}
