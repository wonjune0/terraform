variable "pjt_name" {
  type = string
}

variable "prisubnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_admin_user" {
  type = string
}

variable "db_admin_password" {
  type = string
}
