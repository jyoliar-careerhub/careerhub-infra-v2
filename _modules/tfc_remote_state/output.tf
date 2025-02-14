output "outputs" {
  value = {
    for workspace, remote in data.terraform_remote_state.this :
    workspace => remote.outputs
  }
}
