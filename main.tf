data "aws_elb_service_account" "main_account" {}

data "aws_caller_identity" "current" {}

resource "aws_lb" "lb" {
  name               = "${var.name}-alb"
  load_balancer_type = "${var.type}"
  internal           = "${var.internal}"
  security_groups    = ["${var.security_group_ids}"]
  idle_timeout       = "${var.idle_timeout}"
  subnets            = ["${var.subnet_ids}"]

  access_logs {
    bucket = "${aws_s3_bucket.alb_access_log_bucket.bucket}"
  }

  tags {
    Name = "${var.name}-alb"
  }
}

resource "aws_alb_target_group" "default_target_group" {
  name     = "${var.name}-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "https_listener" {
  count             = "${var.enable_https_listener == true ? 1 : 0}"
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.https_port}"
  protocol          = "HTTPS"
  ssl_policy        = "${var.security_policy}"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  count             = "${var.enable_http_listener == true ? 1 : 0}"
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_s3_bucket" "alb_access_log_bucket" {
  bucket        = "${var.name}-alb-access-logs"
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
      "Resource": "arn:aws:s3:::${var.name}-alb-access-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main_account.arn}"
      }
    }
  ]
}
EOF

  lifecycle_rule {
    id      = "${var.name}-alb-access-logs-lifecycle"
    prefix  = ""
    enabled = "${var.log_expiration_enabled}"
    expiration {
      days = "${var.log_expires_after}"
    }
  }

  tags {
    Name = "${var.name}-alb-access-logs"
  }
}
