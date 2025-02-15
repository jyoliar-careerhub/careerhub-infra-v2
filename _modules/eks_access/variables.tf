variable "cluster_name" {
  type = string
}

variable "cluster_admin_arns" {
  type = list(string)
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
