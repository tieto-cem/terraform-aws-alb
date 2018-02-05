provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
}

module "alb_sg" {
  source      = "github.com/tieto-cem/terraform-aws-sg?ref=v0.1.0"
  name        = "alb-example-sg"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"
  allow_cidrs = {
    "80" = ["0.0.0.0/0"]
  }
}
module "ec2_instance_sg" {
  source = "github.com/tieto-cem/terraform-aws-sg?ref=v0.1.0"
  name   = "alb-example-instance-sg"
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  allow_sgs {
    "80"    = "${module.alb_sg.id}"
    "Count" = 1
  }
}

resource "aws_instance" "alb_example_instance" {
  ami                         = "ami-d834aba1"
  instance_type               = "t2.nano"
  subnet_id                   = "${element(data.aws_subnet_ids.public_subnet_ids.ids, 0)}"
  vpc_security_group_ids      = ["${module.ec2_instance_sg.id}"]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd24
echo "<html><h1>ALB Example</h1></html>" > /var/www/html/index.html
service httpd start
EOF

  tags {
    Name = "alb-example-instance"
  }
}

module "alb" {
  source                 = ".."
  name            = "alb-example"
  lb_internal            = false
  lb_subnet_ids          = "${data.aws_subnet_ids.public_subnet_ids.ids}"
  lb_security_group_ids  = ["${module.alb_sg.id}"]
  tg_vpc_id              = "${data.aws_vpc.default_vpc.id}"
  http_listener_enabled  = true
  https_listener_enabled = false
}

resource "aws_alb_target_group_attachment" "instance_attachment" {
  target_group_arn = "${module.alb.target_group_arn}"
  target_id        = "${aws_instance.alb_example_instance.id}"
  port             = 80
}

output "test_url" {
  value = "http://${module.alb.alb_dns_name}"
}