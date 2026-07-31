variable "pjt_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "prisubnet_ids" {
  type = list(string)
}
