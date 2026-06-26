data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================
# NETWORK LAYER
# ============================================================

module "vpc" {
  source = "../../modules/network-layer/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

module "subnets" {
  source = "../../modules/network-layer/subnets"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones

  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnets"
  })
}

module "route_tables" {
  source = "../../modules/network-layer/route_tables"

  project_name = var.project_name
  environment  = var.environment

  availability_zones = var.availability_zones

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id

  public_subnet_ids      = module.subnets.public_subnet_ids
  private_app_subnet_ids = module.subnets.private_app_subnet_ids
  private_db_subnet_ids  = module.subnets.private_db_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  })
}

module "nat" {
  source = "../../modules/network-layer/nat"

  project_name = var.project_name
  environment  = var.environment

  availability_zones = var.availability_zones

  public_subnet_ids_by_az       = module.subnets.public_subnet_ids_by_az
  private_route_table_ids_by_az = module.route_tables.private_route_table_ids_by_az

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat_gateway"
  })
}

module "security_groups" {
  source = "../../modules/security-layer/security_groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = var.vpc_cidr
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_port         = var.app_port
  db_port          = var.db_port

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-SG"
  })
}

module "endpoints" {
  source = "../../modules/network-layer/endpoints"

  project_name = var.project_name
  environment  = var.environment

  aws_region = var.aws_region

  vpc_id = module.vpc.vpc_id

  private_route_table_ids = module.route_tables.private_route_table_ids

  subnet_ids = module.subnets.private_app_subnet_ids

  endpoint_security_group_ids = [module.security_groups.endpoint_sg_id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-endpoints"
  })
}

module "iam" {
  source = "../../modules/security-layer/iam"

  project_name = var.project_name
  environment  = var.environment

  aws_region = var.aws_region
  account_id = data.aws_caller_identity.current.account_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-iam"
  })
}

module "flow_logs" {
  source = "../../modules/observability/flow_logs"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.vpc.vpc_id
  flow_logs_role_arn = module.iam.flow_logs_role_arn
  retention_days     = 7
  traffic_type       = "ALL"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-flow_logs"
  })
}

