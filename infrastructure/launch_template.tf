resource "aws_key_pair" "vprofile_key_pair" {
  key_name   = "vprofile-key"
  public_key = file("${path.module}/keys/id_rsa.pub")
}

resource "aws_security_group" "vprofile_ec2_instance_sg" {
  name        = "secg-vprofile-ec2-instance"
  description = "Security group for the vprofile ec2 instances"
  vpc_id      = aws_vpc.vprofile_vpc.id

  ingress {
    description = "Allow SSH access from the jumper server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      aws_security_group.jumper_server_sg.id
    ]
  }

  ingress {
    description = "Allow HTTP from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.vprofile_alb_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "vprofile_launch_template" {
  name                   = "vprofile-launch-template"
  description            = "Launch template for vprofile ec2 instances"
  image_id               = var.launch_template_image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.vprofile_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.vprofile_ec2_instance_sg.id]
  update_default_version = true
  iam_instance_profile {
    name = var.instance_profile_name
  }
  
  tags = {
    "Name" = "vprofile-launch-template"
  }
}
