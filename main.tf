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
  pub_subnets    = var.pub_subnets
  pri_subnets    = var.pri_subnets
  db_subnets     = var.db_subnets
  pjt_name       = var.pjt_name
}

module "route_table" {
  source      = "./modules/route_table_module"
  vpc_id      = module.vpc.vpc_id
  igw_id      = module.vpc.igw_id
  pub_subnets = module.subnet.pubsubnet_ids_map
  pri_subnets = module.subnet.prisubnet_ids_map
  pjt_name    = var.pjt_name
}

module "vpc_endpoint" {
  source                   = "./modules/vpc_endpoint_module"
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr_block           = var.vpc_cidr_block
  private_subnet_ids_list  = module.subnet.prisubnet_ids_list
  private_route_table_ids  = module.route_table.pri_rt_ids
  s3_endpoint_service_name = var.s3_endpoint_service_name
  vpc_ecr_sg_id            = module.security_groups.vpc_ecr_sg_id
  ecr_api                  = var.ecr_api
  ecr_dkr                  = var.ecr_dkr
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
  pubsubnet_ids_list             = module.subnet.pubsubnet_ids_list
  pjt_name                       = var.pjt_name
  cloudfront_secret_header_value = random_password.cloudfront_secret.result
}

module "s3" {
  source                      = "./modules/s3_module"
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  pjt_name                    = var.pjt_name
}

module "iam" {
  source                      = "./modules/iam_module"
  db_master_secret_arn        = module.db.db_master_secret_arn
  jwt_secret_arn              = module.backend_secrets.jwt_secret_arn
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  pjt_name                    = var.pjt_name
}

module "ecs" {
  source                  = "./modules/ecs_module"
  ecs_task_execution_arn  = module.iam.ecs_task_execution_role_arn
  ecr_url                 = module.ecr.ecr_url
  private_subnet_ids_list = module.subnet.prisubnet_ids_list
  ecs_sg_id               = module.security_groups.ecs_sg_id
  alb_target_group_arn    = module.alb.alb_target_group_arn
  db_cluster_endpoint     = module.db.db_cluster_endpoint
  db_name                 = var.db_name
  db_admin_user           = var.db_admin_user
  db_master_secret_arn    = module.db.db_master_secret_arn
  image_tag               = var.image_tag
  jwt_secret_arn          = module.backend_secrets.jwt_secret_arn
  pjt_name                = var.pjt_name

  depends_on = [module.iam]
}

module "cloudfront" {
  source                         = "./modules/cloudfront_module"
  alb_dns_name                   = module.alb.alb_dns_name
  cloudfront_secret_header_value = random_password.cloudfront_secret.result
  sub_domain                     = var.sub_domain
  acm_certificate_arn            = module.acm.acm_certificate_arn
  frontend_bucket_name           = module.s3.frontend_bucket_name
  pjt_name                       = var.pjt_name
}

module "acm" {
  source      = "./modules/acm_module"
  domain_name = var.domain_name
  sub_domain  = var.sub_domain
  providers = {
    aws = aws.us_east_1
  }
}

module "route53" {
  source                    = "./modules/route53_module"
  domain_name               = var.domain_name
  sub_domain                = var.sub_domain
  cloudfront_domain_name    = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
  hosted_zone_id            = module.acm.hosted_zone_id
}

module "db" {
  source        = "./modules/db_module"
  dbsubnet_ids  = module.subnet.dbsubnet_ids
  vpc_id        = module.vpc.vpc_id
  ecs_sg_id     = module.security_groups.ecs_sg_id
  db_name       = var.db_name
  db_admin_user = var.db_admin_user
  pjt_name      = var.pjt_name
}

module "sns" {
  source      = "./modules/notification_module"
  alarm_email = var.alarm_email
  pjt_name    = var.pjt_name
}

module "cloudwatch" {
  source              = "./modules/cloudwatch_module"
  sns_topic_arn       = module.sns.sns_topic_arn
  alb_targetgroup_arn = module.alb.alb_target_group_arn
  alb_arn             = module.alb.alb_arn
  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name
  db_instance_ids     = module.db.db_instance_ids
  pjt_name            = var.pjt_name
}

module "backup" {
  source             = "./modules/backup_module"
  db_backup_role_arn = module.iam.db_backup_role_arn
  db_cluster_arn     = module.db.db_cluster_arn
  pjt_name           = var.pjt_name

  providers = {
    aws                = aws
    aws.ap_northeast_3 = aws.ap_northeast_3
  }
}

module "backend_secrets" {
  source   = "./modules/backend_secrets_module"
  pjt_name = var.pjt_name
}


