
resource "aws_iam_role" "eks" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_security_group" "eks" {
  name        = "${var.name}-eks-sg"
  description = "Security group for EKS Cluster"
  vpc_id      = var.vpc_id

  # EKS 클러스터 -> 노드로의 통신 허용 (TCP 443)
  ingress {
    description = "Allow worker node communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "this" {
  name = var.name

  access_config {
    bootstrap_cluster_creator_admin_permissions = false
    authentication_mode                         = "API" #TODO: API_AND_CONFIGMAP 
  }

  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true

    subnet_ids = var.subnet_ids
    security_group_ids = [
      aws_security_group.eks.id,
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
  ]
}


data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity.0.oidc.0.issuer
}
