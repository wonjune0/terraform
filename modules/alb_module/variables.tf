variable "pjt_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "pubsubnet_ids" {
  type = list(string)
}

variable "cloudfront_secret_header_value" {
  type = string
}
