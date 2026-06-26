# ############################################
# # GLOBAL LOCALS (Shared across ALL modules)
# ############################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Primary tag used company-wide for resource identification.
  # Name value follows: {project}-{env}-{tier}-{resource-type}
  # All modules receive `common_tags` and merge it with a local Name tag.
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Region      = var.aws_region
  }
}
