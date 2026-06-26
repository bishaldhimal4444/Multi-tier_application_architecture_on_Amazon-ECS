variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "desired_count" {
  default = 2
}

variable "container_image" {
  default = "public.ecr.aws/aws-containers/retail-store-sample-ui:1.2.3"
}

variable "container_port" {
  default = 8080
}

variable "cpu" {
  default = 1024
}

variable "memory" {
  default = 2048
}

variable "tags" {
  type    = map(string)
  default = {}
}

