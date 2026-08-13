resource "aws_vpc_endpoint" "tf_s3_gw" {
  vpc_id            = var.vpc_id
  service_name      = var.s3_endpoint_service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids[*]

  tags = {
    Name = "${var.pjt_name}_s3_gw_ep"
  }
}


resource "aws_vpc_endpoint" "tf_ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = var.ecr_api
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids_list
  security_group_ids  = [var.vpc_ecr_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.pjt_name}_ecr_api_endpoint"
  }
}

resource "aws_vpc_endpoint" "tf_ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = var.ecr_dkr
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids_list
  security_group_ids  = [var.vpc_ecr_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.pjt_name}_ecr_dkr_endpoint"
  }
}
