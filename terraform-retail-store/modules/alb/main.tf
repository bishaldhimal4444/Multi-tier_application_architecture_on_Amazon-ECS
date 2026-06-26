resource "aws_lb" "this" {

  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}

resource "aws_lb_target_group" "ui" {

  name        = "${local.name_prefix}-ui-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ui-tg"
    }
  )
}


resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type             = "forward"
    target_group_arn = aws_lb_target_group.ui.arn

  }

}

