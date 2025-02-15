locals {
  cluster_admins = merge(
    {
      for admin_arn in var.cluster_admin_arns : admin_arn => {
        principal_arn     = admin_arn
        kubernetes_groups = []
        username          = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        type              = "STANDARD"
      }
    },
    { for entry in var.access_entries : entry.principal_arn => entry }
  )
}


resource "aws_eks_access_entry" "this" {
  for_each = local.cluster_admins

  cluster_name      = var.cluster_name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type
}

resource "aws_eks_access_policy_association" "this" {
  for_each = aws_eks_access_entry.this

  cluster_name  = var.cluster_name
  policy_arn    = local.cluster_admins[each.key].username
  principal_arn = local.cluster_admins[each.key].principal_arn

  access_scope {
    type = "cluster"
  }
}
