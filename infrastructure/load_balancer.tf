resource "aws_security_group" "vprofile_alb_sg" {
  name = "secg-vprofile-alb"
  description = "Security group for the vprofile alb"
  vpc_id = aws_vpc.vprofile_vpc.id

  ingress {
    description = "Allow HTTP access from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "vprofile_alb" {
  name = "vprofile-alb"
  internal = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.vprofile_public_subnet_1a.id,
    aws_subnet.vprofile_public_subnet_1b.id
  ]

  security_groups = [
    aws_security_group.vprofile_alb_sg.id
  ]

  ip_address_type = "ipv4"

  access_logs {
    enabled = true
    bucket = var.bucket_name
    prefix = "logs"
  }
}

resource "aws_lb_listener" "vprofile_alb_listener" {
  load_balancer_arn = aws_alb.vprofile_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.vprofile_target_group.arn
  }
}

output "vprofile_alb_dns_name" {
  value = aws_alb.vprofile_alb.dns_name
}