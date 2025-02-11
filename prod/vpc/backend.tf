terraform {
  backend "remote" {
    organization = "jyoliar-careerhub"
    workspaces {
      name = "prod-vpc"
    }
  }
}
