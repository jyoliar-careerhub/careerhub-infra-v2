module "nat" {
  source = "../../_modules/nat"

  name = "${var.env}-careerhub-nat"

  public_subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  route_table_id   = data.terraform_remote_state.vpc.outputs.private_route_table_id
}
