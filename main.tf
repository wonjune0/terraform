module "vpc" {
  source   = "./modules/vpc_module"
  pjt_name = var.pjt_name
  vpc_cidr = var.vpc_cidr_block
}
