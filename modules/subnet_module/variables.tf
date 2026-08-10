variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "pjt_name" {
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

