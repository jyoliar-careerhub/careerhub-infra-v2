locals {
  eks_ws = "${var.env}-eks"
}

module "remote_state" {
  source = "../../_modules/tfc_remote_state"

  workspaces = [local.eks_ws]
}

locals {
  eks_outputs = module.remote_state.outputs[local.eks_ws]
}
