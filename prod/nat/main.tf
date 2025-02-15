module "nat" {
  source = "../../_modules/nat"

  name = "${var.env}-careerhub-nat"

  public_subnet_id = local.vpc_outputs.public_subnet_ids[0]
  route_table_id   = local.vpc_outputs.private_route_table_id
}

module "prevent_destroy" {
  source = "../../_modules/tfc_prevent_destroy"

  depends_on = [module.nat]
}
output "ws_data" {
  value = module.prevent_destroy.ws_data
}
output "ws_name" {
  value = module.prevent_destroy.ws_name
}
output "terraform_data" {
  value = module.prevent_destroy.terraform_data
}
