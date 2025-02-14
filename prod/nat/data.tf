locals {
  vpc_ws = "${var.env}-vpc"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [vpc_ws]
}

locals {
  vpc_outputs = module.remote_state.outputs[vpc_ws]
}
