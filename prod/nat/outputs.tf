output "instance_id" {
  description = "The ID of the NAT instance"
  value       = module.nat.instance_id
}

output "ssh_key_name" {
  description = "The name of the SSH key pair"
  value       = module.nat.ssh_key_name
}

output "private_ssh_key_secret_id" {
  description = "The ID of the secret containing the private SSH key"
  value       = module.nat.private_ssh_key_secret_id
}

output "route_id" {
  description = "The ID of the route table entry"
  value       = module.nat.route_id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.nat.security_group_id
}
