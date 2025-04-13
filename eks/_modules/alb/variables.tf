variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allow_access_all" {
  type = bool
}

variable "is_internal" {
  type = bool
}

variable "is_https" {
  type = bool
}

variable "health_check_path" {
  type = string
}

variable "is_ssl_redirect" {
  type = bool

  validation {
    condition     = var.is_https || !var.is_ssl_redirect
    error_message = "is_ssl_redirect can only be true when is_https is true."
  }
}

variable "certificate_arn" {
  type    = string
  default = ""

  validation {
    condition     = !var.is_https || length(var.certificate_arn) > 0
    error_message = "certificate_arn is required when is_https is true."
  }
}

#아래 변수들은 default 값이 존재
variable "target_port" {
  type    = number
  default = 80
}

variable "target_protocol" {
  type    = string
  default = "HTTP"
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "alb_tags" {
  type    = map(string)
  default = {}
}

variable "logs_bucket_tags" {
  type    = map(string)
  default = {}
}

variable "security_group_tags" {
  type    = map(string)
  default = {}
}

variable "target_group_tags" {
  type    = map(string)
  default = {}
}
