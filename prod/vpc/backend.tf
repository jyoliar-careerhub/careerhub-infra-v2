terraform {
  cloud {
    organization = "jyoliar-careerhub"
    workspaces {
      tags = {
        infra = "vpc"
      }
    }
  }
}
