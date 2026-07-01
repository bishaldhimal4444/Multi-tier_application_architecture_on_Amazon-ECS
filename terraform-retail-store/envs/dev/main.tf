module "vpc" {

  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "security_groups" {

  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  tags = local.common_tags

}


module "iam" {

  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags

}



module "cloudwatch" {

  source = "../../modules/cloudwatch"

  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags

}


module "alb" {

  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  alb_security_group_id = module.security_groups.alb_sg_id

  tags = local.common_tags

}



module "ecs" {

  source = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  cluster_name = "${var.project_name}-${var.environment}"

  aws_region = var.aws_region

  ui_theme = var.ui_theme

  private_subnet_ids = module.vpc.private_subnet_ids

  ecs_security_group_id = module.security_groups.ecs_ui_sg_id

  target_group_arn = module.alb.ui_target_group_arn

  execution_role_arn = module.iam.ecs_task_execution_role_arn

  task_role_arn = module.iam.ecs_task_role_arn

  log_group_name = module.cloudwatch.ecs_log_group_name

  tags = local.common_tags

}


