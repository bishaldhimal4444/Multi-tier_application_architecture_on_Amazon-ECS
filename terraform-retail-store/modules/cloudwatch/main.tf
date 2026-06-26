resource "aws_cloudwatch_log_group" "ecs" {

  name              = "/ecs/${local.name_prefix}"
  retention_in_days = var.retention_in_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ecs-log-group"
    }
  )

}