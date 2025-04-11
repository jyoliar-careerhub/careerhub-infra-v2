locals {
  node_group = {
    "app" = {
      ng_name        = "ng-app"
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      instance_types = ["t4g.small"]
      ami_type       = "AL2023_ARM_64_STANDARD"
    }
    # "monitoring" = {
    #   ng_name        = "ng-monitoring"
    #   min_size       = 1
    #   max_size       = 1
    #   desired_size   = 1
    #   instance_types = ["t4g.medium"]
    #   ami_type       = "AL2023_ARM_64_STANDARD"
    # }
  }
}


module "eks" {
  source = "../_modules/eks"

  name       = "${var.env}-eks"
  subnet_ids = local.eks_subnets_outputs.public_subnet_ids
  vpc_id     = local.eks_subnets_outputs.vpc_id
}


module "node_group" {
  source = "../_modules/node_group"

  for_each = local.node_group

  vpc_id       = local.eks_subnets_outputs.vpc_id
  subnet_ids   = local.eks_subnets_outputs.public_subnet_ids
  cluster_name = module.eks.eks_cluster_name
  eks_version  = module.eks.eks_version

  name           = "${var.env}-${each.value.ng_name}"
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  desired_size   = each.value.desired_size
  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
}


data "aws_caller_identity" "terraform" {}

data "aws_iam_role" "terraform" {
  name = element(split("/", data.aws_caller_identity.terraform.arn), 1)
}

module "eks_access" {
  source = "../_modules/eks_access"

  cluster_name = module.eks.eks_cluster_name

  cluster_admin_arns = concat(var.cluster_admin_arns, [data.aws_iam_role.terraform.arn])
}

data "aws_acm_certificate" "issued" {
  domain   = var.acm_cert_domain
  statuses = ["ISSUED"]
}

module "eks_alb" {
  source = "../_modules/alb"

  name            = "${var.env}-eks-alb"
  vpc_id          = local.eks_subnets_outputs.vpc_id
  subnet_ids      = local.eks_subnets_outputs.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.issued.arn

  is_internal      = false
  is_https         = true
  is_ssl_redirect  = true
  allow_access_all = true
}


# module "role_for_sa" {
#   source = "../_modules/role_for_sa"

#   eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
#   namespace             = "kube-system"
#   service_account_name  = "aws-load-balancer-controller"
# }
