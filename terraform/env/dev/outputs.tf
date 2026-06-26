########################################
# NETWORK OUTPUTS
########################################

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (one per AZ)."
  value       = module.subnets.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of private application subnet IDs (one per AZ)."
  value       = module.subnets.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs (one per AZ)."
  value       = module.subnets.private_db_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs (one per AZ)."
  value       = module.nat.nat_gateway_ids
}

########################################
# SECURITY OUTPUTS
########################################

output "web_security_group_id" {
  description = "Security group ID for the web/internet-facing tier."
  value       = module.security_groups.web_sg_id
}

output "app_security_group_id" {
  description = "Security group ID for the application tier."
  value       = module.security_groups.app_sg_id
}

output "db_security_group_id" {
  description = "Security group ID for the database tier."
  value       = module.security_groups.db_sg_id
}

output "endpoint_security_group_id" {
  description = "Security group ID attached to all Interface VPC endpoints."
  value       = module.security_groups.endpoint_sg_id
}

########################################
# IAM OUTPUTS
########################################

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile to attach to app servers."
  value       = module.iam.ec2_instance_profile
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role."
  value       = module.iam.ec2_role_arn
}

########################################
# OBSERVABILITY OUTPUTS
########################################

output "flow_log_id" {
  description = "ID of the VPC Flow Log resource."
  value       = module.flow_logs.flow_log_id
}

output "flow_logs_log_group_name" {
  description = "CloudWatch Log Group name for VPC flow logs. Use for Insights queries and metric filters."
  value       = module.flow_logs.log_group_name
}

output "flow_logs_log_group_arn" {
  description = "CloudWatch Log Group ARN for VPC flow logs. Use for subscription filters."
  value       = module.flow_logs.log_group_arn
}
