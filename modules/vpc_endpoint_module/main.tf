resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id            = var.vpc_id
  service_name      = var.s3_endpoint_service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids[*]

  tags = {
    Name = "${var.pjt_name}_s3_gw_ep"
  }
}
