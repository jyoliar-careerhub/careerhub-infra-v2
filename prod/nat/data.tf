locals {
  vpc_ws = "${var.env}-vpc"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.vpc_ws]
}

output "vpc_outputs" {
  value = module.remote_state.outputs
}

locals {
  vpc_outputs = module.remote_state.outputs[local.vpc_ws]
}
