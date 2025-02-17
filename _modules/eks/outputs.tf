output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "eks_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}
