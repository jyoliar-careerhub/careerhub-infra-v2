variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_size" {
  type = number
}

variable "instance_types" {
  type = list(string)
}

variable "ami_type" {
  type    = string
  default = "AL2023_ARM_64_STANDARD"
}

variable "update_config" {
  type    = number
  default = 1
}
