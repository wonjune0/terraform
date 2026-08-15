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
  default = "initial"
}

variable "ecr_api" {
  type = string
}

variable "ecr_dkr" {
  type = string
}

# 재고 차감 방식. ATOMIC이 운영 기본값이고, NONE/PESSIMISTIC은 부하 테스트에서
# 비교하기 위한 값이다. NONE은 초과 판매가 나므로 측정 목적 외에는 쓰지 않는다.
variable "stock_strategy" {
  type    = string
  default = "ATOMIC"

  validation {
    condition     = contains(["ATOMIC", "PESSIMISTIC", "NONE"], var.stock_strategy)
    error_message = "stock_strategy must be one of ATOMIC, PESSIMISTIC, NONE."
  }
}

# 결제 실패를 헤더로 유발할 수 있게 할지 여부. 시연 촬영 때만 true로 올린다.
variable "payment_allow_forced_failure" {
  type    = bool
  default = false
}
