variable "pjt_name" {
  type = string
}

variable "ecs_task_execution_arn" {
  type = string
}

variable "ecr_url" {
  type = string
}

variable "private_subnet_ids_list" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "db_cluster_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_admin_user" {
  type = string
}

variable "db_master_secret_arn" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "jwt_secret_arn" {
  type = string
}
