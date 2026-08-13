variable "vpc_id" {
  type = string
}
variable "igw_id" {
  type = string
}

variable "pub_subnets" {
  type = map(string)
}

variable "pri_subnets" {
  type = map(string)
}

variable "pjt_name" {
  type = string
}
