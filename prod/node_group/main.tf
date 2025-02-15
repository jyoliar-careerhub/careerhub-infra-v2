locals {
  node_group = {
    "app" = {
      name           = "app-ng"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t4g.small"]
      ami_type       = "AL2023_ARM_64_STANDARD"
    }
    "monitoring" = {
      name           = "monitoring-ng"
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t4g.medium"]
      ami_type       = "AL2023_ARM_64_STANDARD"
    }
  }
}

module "node_group" {
  source = "../../_modules/node_group"

  for_each = local.node_group

  vpc_id       = local.eks_outputs.vpc_id
  subnet_ids   = local.eks_outputs.public_subnet_ids
  cluster_name = local.eks_outputs.eks_cluster_name

  name           = "${var.env}-${each.value.name}"
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  desired_size   = each.value.desired_size
  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
}
