variable "name" {
  description = "Name the ALB"
}

#----------------------
# ALB settings
#----------------------

variable "lb_subnet_ids" {
  description = "A list of subnet IDs to attach to the LB"
  type        = "list"
}

variable "lb_security_group_ids" {
  description = "Security groups to associated with the ALB. Security group is created automatically if not specified"
  type        = "list"
  default     = []
}

variable "lb_internal" {
  description = "Whether ALB is internal (= true) or Internet facing (= false)"
  default     = false
}

variable "lb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle before it is closed. This affects both inbound and outbound connections"
  default     = 60
}

#--------------------------------
# Default Target Group settings - variables have tg_ prefix
#--------------------------------

variable "tg_vpc_id" {
  description = "The identifier of the VPC in which to create the target group"
}

variable "tg_deregistration_delay" {
  description = "The amount time in seconds to wait before changing the state of a deregistering target from draining to unused"
  default     = 5
}

variable "tg_port" {
  description = "The port on which targets receive traffic, unless overridden when registering a specific target"
  default     = 80
}

variable "tg_protocol" {
  description = "The protocol to use for routing traffic to the targets. Either HTTP or HTTPS"
  default     = "HTTP"
}

variable "tg_health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  default     = 5
}

variable "tg_health_check_port" {
  description = "The port to use to connect with the target. Valid values are either ports 1-65536, or traffic-port. Defaults to traffic-port."
  default     = "traffic-port"
}
variable "tg_health_check_path" {
  description = "The destination for the health check request"
  default     = "/"
}

variable "tg_health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = 2
}
variable "tg_health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = 3
}

variable "tg_health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  default     = 3
}

variable "tg_health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  default     = "200"
}
#--------------------------------------------
# Default target group health check settings
#--------------------------------------------

#--------------------------
# HTTP listener settings
#--------------------------

variable "http_listener_enabled" {
  description = "Whether to create HTTP listener or not"
}

variable "http_listener_port" {
  description = "Port to listen for HTTP connections"
  default     = 80
}

#--------------------------
# HTTPS listener settings
#--------------------------

variable "https_listener_enabled" {
  description = "Whether to create HTTPS listener or not"
}

variable "https_listener_port" {
  description = "Port to listen for HTTPS connections"
  default     = 443
}

variable "https_listener_certificate_arn" {
  description = "The ARN of the SSL server certificate. Can be ACM managed or IAM certificate. Certificate is required if HTTPS listener is enabled"
  default     = ""
}

variable "https_listener_ssl_policy" {
  description = "The name of the SSL Policy for the HTTPS listener. Required if HTTPS listener is enabled"
  default     = "ELBSecurityPolicy-2016-08"
}


#-----------------------------
# Access logging settings
#-----------------------------

variable "log_expiration_enabled" {
  description = "Whether enable access log object expiration or not"
  default     = false
}

variable "log_expires_after" {
  description = "Days after log files are expired. "
  default     = 30
}

variable "log_force_destroy" {
  description = "Whether access log bucket should be destroyed even if it contains objects or not"
  default     = true
}
