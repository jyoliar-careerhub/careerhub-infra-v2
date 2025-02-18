output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "A list of all public subnets, containing the full objects."
  value       = [for subnet in module.vpc.public_subnet_objects : subnet.id]
}

output "private_subnet_ids" {
  description = "A list of all private subnets, containing the full objects."
  value       = [for subnet in module.vpc.private_subnet_objects : subnet.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.vpc.private_route_table_id
}
