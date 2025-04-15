output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "namespace" {
  value = var.namespace
}

output "service_account_name" {
  value = var.service_account_name
}
