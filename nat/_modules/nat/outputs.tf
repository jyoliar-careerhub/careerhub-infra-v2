output "instance_id" {
  description = "The ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "ssh_key_name" {
  description = "The name of the SSH key pair"
  value       = aws_key_pair.this.key_name
}

output "private_ssh_key_secret_id" {
  description = "The ID of the secret containing the private SSH key"
  value       = aws_secretsmanager_secret.nat_private_key.id
}

output "route_id" {
  description = "The ID of the route table entry"
  value       = aws_route.nat_gateway.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.nat_instance_sg.id
}
