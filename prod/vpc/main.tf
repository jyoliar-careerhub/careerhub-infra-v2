module "vpc" {
  source = "../../_modules/vpc"
  name   = "${var.env}-careerhub"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = [{
    cidr_block = "10.0.1.0/24"
    }, {
    cidr_block = "10.0.2.0/24"
    }, {
    cidr_block = "10.0.3.0/24"
    }
  ]


  private_subnets = [{
    cidr_block = "10.0.101.0/24"
    }, {
    cidr_block = "10.0.102.0/24"
    }, {
    cidr_block = "10.0.103.0/24"
    }
  ]
}
