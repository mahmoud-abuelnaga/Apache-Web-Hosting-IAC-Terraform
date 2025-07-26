data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_key_pair" "jumper_server_key_pair" {
  key_name = "jumper-server-key"
  public_key = file("${path.module}/keys/id_ed25519.pub")
}

resource "aws_security_group" "jumper_server_sg" {
  name = "secg-jumper-server"
  description = "Security group for the jumper server"
  vpc_id = aws_vpc.vprofile_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }
}

resource "aws_instance" "jumper_server" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = aws_key_pair.jumper_server_key_pair.key_name
  subnet_id = aws_subnet.vprofile_public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.jumper_server_sg.id]

  tags = {
    "Name" = "jumper-server"
  }
}