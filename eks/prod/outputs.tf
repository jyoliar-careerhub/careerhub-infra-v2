output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "vpc_id" {
  value = local.vpc_outputs.vpc_id
}

output "public_subnet_ids" {
  value = local.vpc_outputs.public_subnet_ids
}
