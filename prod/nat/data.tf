data "terraform_remote_backend" "vpc" {
  backend = "remote"

  config = {
    organization = var.organization
    workspaces = {
      name = "${var.env}-vpc"
    }
  }
}
