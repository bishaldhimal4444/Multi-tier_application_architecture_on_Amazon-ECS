resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
    }
  )
}



resource "aws_security_group" "ecs_ui" {
  name        = "${local.name_prefix}-ecs-ui-sg"
  description = "ECS UI Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ecs-ui-sg"
    }
  )
}


resource "aws_security_group" "ecs_app" {
  name        = "${local.name_prefix}-ecs-app-sg"
  description = "ECS Application Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ecs-app-sg"
    }
  )
}


resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-db-sg"
  description = "Database Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-sg"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "ecs_ui" {
  security_group_id            = aws_security_group.ecs_ui.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "ecs_ui" {
  security_group_id = aws_security_group.ecs_ui.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_app" {
  security_group_id            = aws_security_group.ecs_app.id
  referenced_security_group_id = aws_security_group.ecs_ui.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "ecs_app" {
  security_group_id = aws_security_group.ecs_app.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "database" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.ecs_app.id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "database" {
  security_group_id = aws_security_group.database.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


