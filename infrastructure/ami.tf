# ami init instance
resource "aws_instance" "ami_init_instance" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = aws_key_pair.jumper_server_key_pair.key_name   # using it temporarily
  subnet_id = aws_subnet.vprofile_public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.jumper_server_sg.id]

  tags = {
    "Name" = "ami-init-instance"
  }

  provisioner "local-exec" {
    command = "sleep ${var.sleep_period}"
    when = create
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts"
    when = create
  }

  connection {
    type = "ssh"
    user = var.instance_user
    private_key = file("${path.module}/keys/id_ed25519")
    host = self.public_ip
  }

  provisioner "file" {
    source = "${path.module}/files/ami_init.sh"
    destination = "/tmp/ami_init.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/ami_init.sh",
      "sudo /tmp/ami_init.sh",
      "rm /tmp/ami_init.sh"
    ]
  }
}