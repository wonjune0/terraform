variable "pjt_name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "alb_target_group_arn_suffix" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "db_instance_ids" {
  type = list(string)
}
