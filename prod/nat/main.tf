module "nat" {
  source = "../../_modules/nat"

  name = "${var.env}-careerhub-nat"

  public_subnet_id = local.vpc_outputs.public_subnet_id
  route_table_id   = local.vpc_outputs.route_table_id
}
