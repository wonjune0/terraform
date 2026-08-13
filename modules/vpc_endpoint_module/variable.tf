variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnet_ids_list" {
  type = list(string)
}

variable "private_route_table_ids" {
  type = list(string)
}

variable "s3_endpoint_service_name" {
  type = string
}

variable "pjt_name" {
  type = string
}

variable "vpc_ecr_sg_id" {
  type = string
}
