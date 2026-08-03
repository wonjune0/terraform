resource "random_password" "cloudfront_secret" {
  length  = 32
  special = false
}



module "vpc" {
  source   = "./modules/vpc_module"
  vpc_cidr = var.vpc_cidr_block
  pjt_name = var.pjt_name
}

module "subnet" {
  source         = "./modules/subnet_module"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  pjt_name       = var.pjt_name
}

module "route_table" {
  source      = "./modules/route_table_module"
  vpc_id      = module.vpc.vpc_id
  igw_id      = module.vpc.igw_id
  pub_subnets = module.subnet.pubsubnet_ids
  pri_subnets = module.subnet.prisubnet_ids
  pjt_name    = var.pjt_name
}

module "vpc_endpoint" {
  source                   = "./modules/vpc_endpoint_module"
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr_block           = var.vpc_cidr_block
  private_subnet_ids       = module.subnet.prisubnet_ids
  private_route_table_ids  = module.route_table.pri_rt_ids
  s3_endpoint_service_name = var.s3_endpoint_service_name
  vpc_ecr_sg_id            = module.security_groups.vpc_ecr_sg_id
  pjt_name                 = var.pjt_name
}

module "ecr" {
  source   = "./modules/ecr_module"
  pjt_name = var.pjt_name
}

module "security_groups" {
  source         = "./modules/security_group_module"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  container_port = 80
  pjt_name       = var.pjt_name
}

module "alb" {
  source                         = "./modules/alb_module"
  vpc_id                         = module.vpc.vpc_id
  alb_sg                         = module.security_groups.alb_sg_id
  pubsubnet_ids                  = module.subnet.pubsubnet_ids
  pjt_name                       = var.pjt_name
  cloudfront_secret_header_value = random_password.cloudfront_secret.result
}

module "s3" {
  source = "./modules/s3_module"
}

module "iam" {
  source   = "./modules/iam_module"
  pjt_name = var.pjt_name
}

module "ecs" {
  source                 = "./modules/ecs_module"
  ecs_task_execution_arn = module.iam.tf_ecs_task_execution_role_arn
  ecr_url                = module.ecr.ecr_url
  private_subnet_ids     = module.subnet.prisubnet_ids
  ecs_sg_id              = module.security_groups.ecs_sg_id
  alb_target_group_arn   = module.alb.alb_target_group_arn
  pjt_name               = var.pjt_name
}

module "cloudfront" {
  source                         = "./modules/cloudfront_module"
  alb_dns_name                   = module.alb.alb_dns_name
  cloudfront_secret_header_value = random_password.cloudfront_secret.result
  sub_domain                     = var.sub_domain
  acm_certificate_arn            = module.route53.acm_certificate_arn
  pjt_name                       = var.pjt_name
}

module "route53" {
  source                    = "./modules/rout53_module"
  domain_name               = var.domain_name
  sub_domain                = var.sub_domain
  cloudfront_domain_name    = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}
