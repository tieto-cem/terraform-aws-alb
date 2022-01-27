data "aws_elb_service_account" "main_account" {}

data "aws_caller_identity" "current" {}

#-------------------------
# Load balancer
#-------------------------
resource "aws_lb" "lb" {
  name               = "${var.name}"
  load_balancer_type = "application"
  internal           = "${var.lb_internal}"
  security_groups    = var.lb_security_group_ids
  idle_timeout       = "${var.lb_idle_timeout}"
  subnets            = var.lb_subnet_ids

  access_logs {
    bucket  = "${aws_s3_bucket.alb_access_log_bucket.bucket}"
    enabled = var.enable_access_logs
  }

  tags = {
    Name = "${var.name}-alb"
  }
}

#--------------------------
#  Default target group
#--------------------------

resource "aws_alb_target_group" "default_target_group" {
  name                 = "${var.name}-default-tg"
  port                 = "${var.tg_port}"
  protocol             = "${var.tg_protocol}"
  vpc_id               = "${var.tg_vpc_id}"

  deregistration_delay = "${var.tg_deregistration_delay}"

  health_check {
    interval = "${var.tg_health_check_interval}"
    path = "${var.tg_health_check_path}"
    port = "${var.tg_health_check_port}"
    protocol = "${var.tg_protocol}"
    healthy_threshold = "${var.tg_health_check_healthy_threshold}"
    unhealthy_threshold = "${var.tg_health_check_unhealthy_threshold}"
    timeout = "${var.tg_health_check_timeout}"
    matcher = "${var.tg_health_check_matcher}"
  }
}

#--------------------------
#  HTTP listener
#--------------------------
resource "aws_lb_listener" "https_listener" {
  count             = "${var.https_listener_enabled ? 1 : 0}"
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.https_listener_port}"
  protocol          = "HTTPS"
  ssl_policy        = "${var.https_listener_ssl_policy}"
  certificate_arn   = "${var.https_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_target_group.arn}"
    type             = "forward"
  }
}

#--------------------------
#  HTTPS listener
#--------------------------
resource "aws_lb_listener" "http_listener" {
  count             = "${var.http_listener_enabled ? 1 : 0}"
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.http_listener_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_target_group.arn}"
    type             = "forward"
  }
}

#--------------------------
#  Access log bucket
#--------------------------
locals {
  bucket_name   = try(var.access_log_bucket_name, "${var.name}-alb-access-logs")
}

resource "aws_s3_bucket" "alb_access_log_bucket" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = "${var.log_force_destroy}"
  policy        = <<EOF
{
  "Id": "ALBAccessLogBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ELBPolicyStatement",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main_account.arn}"
      }
    }
  ]
}
EOF

  lifecycle_rule {
    id      = "${var.name}-access-logs-lifecycle"
    prefix  = ""
    enabled = "${var.log_expiration_enabled}"
    expiration {
      days = "${var.log_expires_after}"
    }
  }

  tags = {
    Name = "${var.name}-access-logs"
  }
}
