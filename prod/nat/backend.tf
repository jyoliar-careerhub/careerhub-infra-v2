terraform {
  backend "remote" {
    organization = "jyoliar-careerhub"
    workspaces {
      name = "prod-nat"
    }
  }
}
