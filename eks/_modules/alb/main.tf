resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  lower   = true
  special = false
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
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_https" {
  count             = var.allow_access_all && var.is_https ? 1 : 0
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_s3_bucket" "lb_logs" {
  bucket        = "${var.name}-logs-${random_string.bucket_suffix.result}"
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

data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowELBRootAccount",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.lb_logs.arn}/*",
        "Principal" : {
          "AWS" : "${data.aws_elb_service_account.this.arn}"
        }
      },
      {
        "Sid" : "AWSLogDeliveryWrite",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.lb_logs.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        },
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        }
      },
      {
        "Sid" : "AWSLogDeliveryAclCheck",
        "Effect" : "Allow",
        "Action" : "s3:GetBucketAcl",
        "Resource" : "${aws_s3_bucket.lb_logs.arn}",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        }
      },
      {
        "Sid" : "AllowALBAccess",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.lb_logs.arn}/*",
        "Principal" : {
          "Service" : "elasticloadbalancing.amazonaws.com"
        }
      }
    ]
  })
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

  depends_on = [aws_s3_bucket.lb_logs]
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
  count = var.is_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

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
