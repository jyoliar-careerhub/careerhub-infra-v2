output "outputs" {
  value = {
    for workspace, remote in data.tfe_outputs.this :
    workspace => remote.values
  }
}

output "nonsensitive_outputs" {
  value = {
    for workspace, remote in data.tfe_outputs.this :
    workspace => {
      for key, value in remote.values :
      key => value.nonsensitive_values
    }
  }
}
