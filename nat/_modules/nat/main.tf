data "aws_subnet" "public" {
  id = var.public_subnet_id
}

data "aws_vpc" "this" {
  id = data.aws_subnet.public.vpc_id
}

resource "aws_security_group" "nat_instance_sg" {
  vpc_id      = data.aws_subnet.public.vpc_id
  name        = "${var.name}-sg"
  description = "Allow SSH and NAT traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-keypair"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_secretsmanager_secret" "nat_private_key" {
  name                    = "${var.name}-private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "nat_private_key_version" {
  secret_id     = aws_secretsmanager_secret.nat_private_key.id
  secret_string = tls_private_key.this.private_key_pem
}

resource "aws_instance" "nat" {
  ami = "ami-00c2fe3c2e5f11a2b" //Amazon Linux 2023 AMI arm64

  instance_type = "t4g.micro"
  key_name      = aws_key_pair.this.key_name
  subnet_id     = var.public_subnet_id

  source_dest_check = false

  user_data = <<EOT
#!/bin/bash

echo "*** Install iptables and start ***"
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables

echo "*** Enable IP forwarding ***"
cat <<EOF | tee /etc/sysctl.d/custom-ip-forwarding.conf
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

echo "*** Configure NAT ***"
/sbin/iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
/sbin/iptables -F FORWARD
service iptables save
  EOT

  vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]
  tags = {
    Name = var.name
  }
}

resource "aws_route" "nat_gateway" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}
