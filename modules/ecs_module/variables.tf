variable "pjt_name" {
  type = string
}

variable "ecs_task_execution_arn" {
  type = string
}

variable "ecr_url" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}
