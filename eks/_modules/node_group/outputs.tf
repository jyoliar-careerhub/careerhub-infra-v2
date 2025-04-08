output "ng_security_group_id" {
  value = aws_security_group.eks_node_sg.id
}

output "ng_key_name" {
  value = aws_key_pair.this.key_name
}

output "ng_secret_name" {
  value = aws_secretsmanager_secret.private_key.name
}
