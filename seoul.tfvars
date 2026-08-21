region_name    = "ap-northeast-2"
pjt_name       = "ecommerce-project"
vpc_cidr_block = "10.0.0.0/16"
pub_subnets = {
  "10.0.1.0/24" = "ap-northeast-2a"
  "10.0.2.0/24" = "ap-northeast-2c"
}
pri_subnets = {
  "10.0.3.0/24" = "ap-northeast-2a"
  "10.0.4.0/24" = "ap-northeast-2c"
}
db_subnets = {
  "10.0.5.0/24" = "ap-northeast-2a"
  "10.0.6.0/24" = "ap-northeast-2c"
}
s3_endpoint_service_name = "com.amazonaws.ap-northeast-2.s3"
domain_name              = "ecommerce-project.shop"
sub_domain               = "www.ecommerce-project.shop"
db_name                  = "test_db"
db_admin_user            = "admin"
alarm_email              = "wonjune7542@gmail.com"
ecr_api                  = "com.amazonaws.ap-northeast-2.ecr.api"
ecr_dkr                  = "com.amazonaws.ap-northeast-2.ecr.dkr"
