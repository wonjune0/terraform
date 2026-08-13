variable "region_name" {
  type = string
}

variable "pjt_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "pub_subnets" {
  type = map(string)
}

variable "pri_subnets" {
  type = map(string)
}

variable "db_subnets" {
  type = map(string)
}

variable "s3_endpoint_service_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "sub_domain" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_admin_user" {
  type = string
}

variable "alarm_email" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "initital"
}

variable "ecr_api" {
  type = string
}

variable "ecr_dkr" {
  type = string
}
