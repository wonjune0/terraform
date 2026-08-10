resource "aws_subnet" "tf_pubsubnet" {
  for_each          = var.pub_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.pjt_name}_pubsubnet_${each.value}"
  }

}

resource "aws_subnet" "tf_prisubnet" {
  for_each          = var.pri_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.pjt_name}_prisubnet_${each.value}"
  }
}

resource "aws_subnet" "tf_dbsubnet" {
  for_each          = var.db_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.key
  availability_zone = each.value
  tags = {
    Name = "${var.pjt_name}_dbsubnet_${each.value}"
  }
}
