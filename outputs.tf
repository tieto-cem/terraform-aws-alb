
output "alb_name" {
  value = "${aws_lb.lb.name}"
}

output "alb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "alb_arn" {
  value = "${aws_lb.lb.arn}"
}

output "alb_id" {
  value = "${aws_lb.lb.id}"
}

output "alb_arn_suffix" {
  value = "${aws_lb.lb.arn_suffix}"
}

output "alb_zone_id" {
  value = "${aws_lb.lb.zone_id}"
}

output "https_listener_arn" {
  value = "${aws_lb_listener.https_listener.0.arn}"
}

output "http_listener_arn" {
  value = "${aws_lb_listener.http_listener.0.arn}"
}

output "default_target_group_arn" {
  value = "${aws_alb_target_group.default_target_group.arn}"
}