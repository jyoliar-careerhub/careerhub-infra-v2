output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "lb_endpoint" {
  value = aws_lb.this.dns_name
}

output "default_sg_id" {
  value = aws_security_group.this.id
}
