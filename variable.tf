variable "region_name" {
  type = string
}

variable "pjt_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = list(string)
}
