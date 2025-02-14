data "tfe_organizations" "this" {
  lifecycle {
    postcondition {
      condition     = length(self.names) == 1
      error_message = "Only one organization is allowed"
    }
  }
}

data "terraform_remote_state" "this" {
  for_each = toset(var.workspaces)

  backend = "remote"
  config = {
    organization = data.tfe_organizations.this.names[0]
    workspaces = {
      name = each.value
    }
  }
}
