provider "aws" {
  region = "us-east-2"
}

variable "cluster_name" {
  description = "A prefix to append to all resource names"
  type = string
  default = "louisl-terraform-tutorial"
}

variable "server_port" {
  description = "The port on which the http server will listen"
  type = number
  default = 8080
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "example-alb" {
  name = "${var.cluster_name}-alb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb" "example" {
  name = "${var.cluster_name}"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.example-alb.id]
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    field = "path-pattern"
    values = ["*"]
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "example-instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "launch-config" {
  image_id           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.example-instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.cluster_name}"
  launch_configuration = aws_launch_configuration.launch-config.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tags = [
    {
      key = "Name"
      value = "${var.cluster_name}"
      propagate_at_launch = true
    },
    {
      key = "Squad"
      value = "Squad4"
      propagate_at_launch = true
    },
    {
      key = "Trender"
      value = "louisl"
      propagate_at_launch = true
    },
    {
      key = "ValidUntil"
      value = "IGNORE"
      propagate_at_launch = true
    }
  ]
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}