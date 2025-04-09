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
