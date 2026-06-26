resource "aws_ecs_cluster" "this" {

  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.cluster_name
    }
  )
}


resource "aws_ecs_task_definition" "ui" {

  family                   = "${local.name_prefix}-ui"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "application"
      image = var.container_image

      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8080/actuator/health || exit 1"
        ]
        interval    = 30
        retries     = 3
        timeout     = 5
        startPeriod = 30
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ui"
        }
      }
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = local.common_tags
}

data "aws_region" "current" {}

resource "aws_ecs_service" "ui" {

  name            = "ui"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ui.arn

  launch_type = "FARGATE"

  desired_count = var.desired_count

  enable_execute_command = true

  network_configuration {

    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = false

  }

  load_balancer {

    target_group_arn = var.target_group_arn

    container_name = "application"

    container_port = var.container_port

  }

  depends_on = [
    aws_ecs_task_definition.ui
  ]

  tags = local.common_tags

}

