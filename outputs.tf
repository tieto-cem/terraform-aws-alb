
output "alb_name" {
  description = "ALB name"
  value = "${aws_lb.lb.name}"
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value = "${aws_lb.lb.dns_name}"
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value = "${aws_lb.lb.arn}"
}

output "alb_id" {
  description = "The ID of the load balancer"
  value = "${aws_lb.lb.id}"
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value = "${aws_lb.lb.arn_suffix}"
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)"
  value = "${aws_lb.lb.zone_id}"
}

output "https_listener_arn" {
  description = "The ARN of the https listener"
  value = "${join("", aws_lb_listener.https_listener.*.arn)}"
}

output "http_listener_arn" {
  description = "The ARN of the http listener"
  value = "${join("", aws_lb_listener.http_listener.*.arn)}"
}

output "target_group_arn" {
  description = "The ARN of the default target group"
  value = "${aws_alb_target_group.default_target_group.arn}"
}

output "access_log_bucket" {
  value = aws_s3_bucket.alb_access_log_bucket
}