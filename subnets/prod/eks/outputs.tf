output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.subnets.vpc_id
}

output "public_subnet_ids" {
  description = "A list of all public subnets, containing the full objects."
  value       = [for subnet in module.subnets.public_subnet_objects : subnet.id]
}

output "private_subnet_ids" {
  description = "A list of all private subnets, containing the full objects."
  value       = [for subnet in module.subnets.private_subnet_objects : subnet.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.subnets.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.subnets.private_route_table_id
}
