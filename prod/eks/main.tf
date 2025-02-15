module "eks" {
  source = "../../_modules/eks"

  name       = "${var.env}-eks"
  subnet_ids = local.vpc_outputs.public_subnet_ids
  vpc_id     = local.vpc_outputs.vpc_id
}
