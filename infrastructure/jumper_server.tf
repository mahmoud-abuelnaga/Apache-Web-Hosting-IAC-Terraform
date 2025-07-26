data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_key_pair" "jumper_server_key_pair" {
  key_name   = "jumper-server-key"
  public_key = file("${path.module}/keys/id_ed25519.pub")
}

resource "aws_security_group" "jumper_server_sg" {
  name        = "secg-jumper-server"
  description = "Security group for the jumper server"
  vpc_id      = aws_vpc.vprofile_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jumper_server" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.jumper_server_key_pair.key_name
  subnet_id              = aws_subnet.vprofile_public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.jumper_server_sg.id]

  provisioner "local-exec" {
    command = "sleep ${var.sleep_period}"
    when    = create
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts"
    when    = create
  }

  connection {
    type        = "ssh"
    user        = var.instance_user
    private_key = file("${path.module}/keys/id_ed25519")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/keys/id_rsa"
    destination = "/home/${var.instance_user}/.ssh/id_rsa"
  }

  tags = {
    "Name" = "jumper-server"
  }
}
