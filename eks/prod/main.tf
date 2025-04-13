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

  vpc_id                     = local.eks_subnets_outputs.vpc_id
  subnet_ids                 = local.eks_subnets_outputs.public_subnet_ids
  cluster_name               = module.eks.eks_cluster_name
  eks_version                = module.eks.eks_version
  cluster_security_group_ids = module.eks.cluster_security_group_ids

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

  name               = "${var.env}-eks-alb"
  vpc_id             = local.eks_subnets_outputs.vpc_id
  subnet_ids         = local.eks_subnets_outputs.public_subnet_ids
  certificate_arn    = data.aws_acm_certificate.issued.arn
  security_group_ids = [for node_group in module.node_group : node_group.allowed_alb_sg_id]

  is_internal      = false
  is_https         = true
  is_ssl_redirect  = true
  allow_access_all = true
}

data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.alb_domain
  type    = "A"

  alias {
    name                   = module.eks_alb.alb_dns_name
    zone_id                = module.eks_alb.alb_zone_id
    evaluate_target_health = true
  }
}

data "http" "aws_lbc_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_lbc" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = data.http.aws_lbc_policy.body
}

module "role_for_sa" {
  source = "../_modules/role_for_sa"

  name                  = "${var.env}-aws-lbc"
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  namespace             = var.aws_lbc_ns
  service_account_name  = var.aws_lbc_sa
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = module.role_for_sa.role_name
  policy_arn = aws_iam_policy.aws_lbc.arn
}
