output "ng_security_group_id" {
  value = aws_security_group.eks_node.id
}

output "allowed_alb_sg_id" {
  value = aws_security_group.allowed_alb.id
}
