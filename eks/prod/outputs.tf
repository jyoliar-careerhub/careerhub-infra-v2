output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "eks_alb_endpoint" {
  value = module.eks_alb.lb_endpoint
}

output "target_group_arn" {
  value = module.eks_alb.target_group_arn
}
