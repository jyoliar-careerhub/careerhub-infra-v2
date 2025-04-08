output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "public_subnet_objects" {
  description = "A list of all public subnets, containing the full objects."
  value       = aws_subnet.public
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = var.public_route_table_id
}

output "private_subnet_objects" {
  description = "A list of all private subnets, containing the full objects."
  value       = aws_subnet.private
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = var.private_route_table_id
}
