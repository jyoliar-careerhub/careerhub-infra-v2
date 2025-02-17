module "eks" {
  source = "../../_modules/eks"

  name       = "${var.env}-eks"
  subnet_ids = local.vpc_outputs.public_subnet_ids
  vpc_id     = local.vpc_outputs.vpc_id
}

data "aws_caller_identity" "terraform" {}

data "aws_iam_role" "terraform" {
  name = element(split("/", data.aws_caller_identity.terraform.arn), 1)
}

module "eks_access" {
  source = "../../_modules/eks_access"

  cluster_name = module.eks.eks_cluster_name

  cluster_admin_arns = [data.aws_iam_role.terraform.arn]
}
