
variable "name" {}

variable "type" {
  default = "application"
  description = "The type of load balancer to create. Possible values are application or network. "
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
  description = "Security groups to associated with the ELB"
}

variable "internal" {
  description = "Whether ALB is internal (= true) or Internet facing (= false)"
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle before it is closed"
  default = 60
}

// http listener setup

variable "enable_http_listener" {}

variable "http_port" {
  default = 80
}

// https listener setup

variable "enable_https_listener" {}

variable "https_port" {
  default = 443
}

variable "certificate_arn" {
  default = ""
  description = "The ARN of the SSL server certificate. Can be ACM managed or IAM certificate."
}

variable "security_policy" {
  default = "ELBSecurityPolicy-2016-08"
}


// access log object lifecycle

variable "log_expiration_enabled" {
  description = "Whether enable access log object expiration or not"
  default = false
}

variable "log_expires_after" {
  description = "Days after log files are expired"
  default = 30
}

variable "log_force_destroy" {
  description = "Whether access log bucket should be destroyed even if it contains objects or not"
  default = true
}
