data "tfe_organizations" "this" {
  lifecycle {
    postcondition {
      condition     = length(self.names) == 1
      error_message = "Only one organization is allowed"
    }
  }
}

data "tfe_workspace" "this" {
  organization = data.tfe_organizations.this.names[0]
  name         = terraform.workspace
}

resource "terraform_data" "this" {
  input = {
    dependencies = [
      data.tfe_workspace.this.remote_state_consumer_ids
    ]
  }
  #   lifecycle {
  #     prevent_destroy = length(self.input.dependencies) > 0
  #   }
}
output "ws_data" {
  value = data.tfe_workspace.this
}

output "ws_name" {
  value = terraform.workspace
}
output "terraform_data" {
  value = terraform_data.this
}
