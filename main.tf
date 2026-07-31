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
  pjt_name                 = var.pjt_name
}
