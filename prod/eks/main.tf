module "eks" {
  source = "../../_modules/eks"

  name       = "${var.env}-eks"
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id
}
