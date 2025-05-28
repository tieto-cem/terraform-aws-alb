data "aws_elb_service_account" "main_account" {}

data "aws_caller_identity" "current" {}

#-------------------------
# Load balancer
#-------------------------
resource "aws_lb" "lb" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.lb_internal
  security_groups    = var.lb_security_group_ids
  idle_timeout       = var.lb_idle_timeout
  subnets            = var.lb_subnet_ids
  
  enable_deletion_protection = var.lb_enable_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.alb_access_log_bucket.bucket
    enabled = var.enable_access_logs
  }

  tags = {
    Name = "${var.name}-alb"
  }
}

#--------------------------
#  Default target group
#--------------------------
/*
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
*/

  locals {
    listener_default_action = var.default_listener_action != null ? var.default_listener_action : {
      type             = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404"
      }
    }
  }


  #--------------------------
  #  HTTP listener
  #--------------------------
  resource "aws_lb_listener" "https_listener" {
    count             = var.https_listener_enabled ? 1 : 0

    load_balancer_arn = aws_lb.lb.arn
    port              = var.https_listener_port
    protocol          = "HTTPS"
    ssl_policy        = var.https_listener_ssl_policy
    certificate_arn   = var.https_listener_certificate_arn

    default_action {
      type             = local.listener_default_action.type

      dynamic "fixed_response" {
        for_each = local.listener_default_action.type == "fixed-response" ? [1] : []
        content {
          content_type = local.listener_default_action.fixed_response.content_type
          message_body = local.listener_default_action.fixed_response.message_body
          status_code  = local.listener_default_action.fixed_response.status_code
        }
      }

      dynamic "forward" {
        for_each = local.listener_default_action.type == "forward" ? [1] : []
        content {
          target_group {
            arn = local.listener_default_action.forward.target_group_arn
          }
        }
      }

      dynamic "redirect" {
        for_each = local.listener_default_action.type == "redirect" ? [1] : []
        content {
          status_code = local.listener_default_action.redirect.status_code
          host        = local.listener_default_action.redirect.host
          path        = local.listener_default_action.redirect.path
          port        = local.listener_default_action.redirect.port
          protocol    = local.listener_default_action.redirect.protocol
          query       = local.listener_default_action.redirect.query
        }
      }
    }
  }

#--------------------------
#  HTTPS listener
#--------------------------
resource "aws_lb_listener" "http_listener" {
  count             = var.http_listener_enabled ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port              = var.http_listener_port
  protocol          = "HTTP"

    default_action {
      type             = local.listener_default_action.type

      dynamic "fixed_response" {
        for_each = local.listener_default_action.type == "fixed-response" ? [1] : []
        content {
          content_type = local.listener_default_action.fixed_response.content_type
          message_body = local.listener_default_action.fixed_response.message_body
          status_code  = local.listener_default_action.fixed_response.status_code
        }
      }

      dynamic "forward" {
        for_each = local.listener_default_action.type == "forward" ? [1] : []
        content {
          target_group {
            arn = local.listener_default_action.forward.target_group_arn
          }
        }
      }

      dynamic "redirect" {
        for_each = local.listener_default_action.type == "redirect" ? [1] : []
        content {
          status_code = local.listener_default_action.redirect.status_code
          host        = local.listener_default_action.redirect.host
          path        = local.listener_default_action.redirect.path
          port        = local.listener_default_action.redirect.port
          protocol    = local.listener_default_action.redirect.protocol
          query       = local.listener_default_action.redirect.query
        }
      }
    }
}

#--------------------------
#  Access log bucket
#--------------------------
locals {
  bucket_name   = var.access_log_bucket_name != null? var.access_log_bucket_name : "${var.name}-alb-access-logs"
}

resource "aws_s3_bucket" "alb_access_log_bucket" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = var.log_force_destroy
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
    enabled = var.log_expiration_enabled
    expiration {
      days = var.log_expires_after
    }
  }

  tags = {
    Name = "${var.name}-access-logs"
  }
}
