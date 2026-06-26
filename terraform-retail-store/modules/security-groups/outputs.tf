output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_ui_sg_id" {
  value = aws_security_group.ecs_ui.id
}

output "ecs_app_sg_id" {
  value = aws_security_group.ecs_app.id
}

output "database_sg_id" {
  value = aws_security_group.database.id
}

