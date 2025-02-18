module "eks_access" {
  source = "../../_modules/eks_access"

  cluster_name = local.eks_outputs.eks_cluster_name

  cluster_admin_arns = var.cluster_admin_arns
  access_entries     = var.access_entries
}
