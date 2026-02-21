resource "aws_lb_target_group" "external-lb-tg" {
  name     = var.external_tg_name
  port     = var.external_tg_port
  protocol = var.external_tg_protocol
  vpc_id   = var.external_vpc_id
}

resource "aws_lb" "external_lb" {
  name               = var.external_lb_name
  internal           = var.ext_internal
  load_balancer_type = var.external_lb_type
  security_groups    = [var.external_lb_sg]
  subnets            = var.external_lb_subnet
}

resource "aws_lb_listener" "external-lb-tg-listener" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = var.external_lb_listener_port
  protocol          = var.external_lb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-lb-tg.arn
  }
}

#creating internal LB

resource "aws_lb_target_group" "internal-lb-tg" {
  name     = var.internal_tg_name
  port     = var.internal_tg_port
  protocol = var.internal_tg_protocol
  vpc_id   = var.internal_vpc_id
}

resource "aws_lb" "internal_lb" {
  name               = var.internal_lb_name
  internal           = var.int_internal
  load_balancer_type = var.internal_lb_type
  security_groups    = [var.internal_lb_sg]
  subnets            = var.internal_lb_subnet
}



resource "aws_lb_listener" "internal-lb-tg-listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = var.internal_lb_listener_port
  protocol          = var.internal_lb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-lb-tg.arn
  }
}