resource "aws_s3_bucket" "lb_logs" {
  bucket        = "${var.name}-logs"
  force_destroy = true


  tags = var.logs_bucket_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = 3
    }
  }
}

resource "aws_security_group" "this" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  tags = var.security_group_tags
}

resource "aws_security_group_rule" "allow_all_http" {
  count             = var.allow_access_all ? 1 : 0
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_https" {
  count             = var.allow_access_all && var.is_https ? 1 : 0
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups    = concat(var.security_group_ids, [aws_security_group.this.id])
  subnets            = var.subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = var.name
    enabled = true
  }

  tags = var.alb_tags
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  vpc_id      = var.vpc_id
  target_type = "ip"
  protocol    = var.target_protocol
  port        = var.target_port

  tags = var.target_group_tags
}

resource "aws_lb_listener" "https" {
  count = (!var.is_ssl_redirect) ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http" {
  count = var.is_ssl_redirect ? 0 : 1

  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  count = (var.is_ssl_redirect && var.is_https) ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
