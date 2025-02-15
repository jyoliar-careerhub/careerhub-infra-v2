data "aws_caller_identity" "terraform" {}

module "eks_access" {
  source = "../../_modules/eks_access"

  cluster_name = local.eks_outputs.eks_cluster_name

  cluster_admin_arns = concat(var.cluster_admin_arns, [data.aws_caller_identity.terraform.arn])
  access_entries     = var.access_entries
}
