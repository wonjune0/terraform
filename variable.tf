variable "region_name" {
  type = string
}

variable "pjt_name" {
  type = string
}

variable "vpc_cider_block" {
  type = string
}

variable "subnets" {
  type = list(string)
}
