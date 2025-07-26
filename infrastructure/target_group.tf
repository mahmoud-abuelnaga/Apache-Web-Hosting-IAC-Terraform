resource "aws_lb_target_group" "vprofile_target_group" {
  name        = "tg-vprofile"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vprofile_vpc.id
  target_type = "instance"

  health_check {
    path = "/"
    protocol = "HTTP"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200-399"
  }
}
