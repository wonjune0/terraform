variable "vpc_id" {
  type = string
}
variable "igw_id" {
  type = string
}

variable "pub_subnets" {
  type = list(string)
}

variable "pri_subnets" {
  type = list(string)
}

variable "pjt_name" {
  type = string
}
