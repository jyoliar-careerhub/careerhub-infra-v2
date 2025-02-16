output "outputs" {
  value = {
    for workspace, remote in data.tfe_outputs.this :
    workspace => remote.values
  }
}
