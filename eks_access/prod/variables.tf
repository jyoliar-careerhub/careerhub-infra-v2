variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "cluster_admin_arns" {
  type    = list(string)
  default = []
}

variable "access_entries" {
  type = list(object({
    principal_arn     = string
    kubernetes_groups = list(string)
    username          = string
    type              = string
  }))

  default = []
}
