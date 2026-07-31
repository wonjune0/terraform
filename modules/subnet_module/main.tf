
resource "aws_subnet" "tf_pubsubnet" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 1)
  availability_zone = count.index % 2 == 0 ? "ap-northeast-2a" : "ap-northeast-2c"
  tags = {
    Name = "${var.pjt_name}_pubsubnet_sn${count.index + 1}"
  }
}

resource "aws_subnet" "tf_prisubnet" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 3)
  availability_zone = count.index % 2 == 0 ? "ap-northeast-2a" : "ap-northeast-2c"
  tags = {
    Name = "${var.pjt_name}_prisubnet_sn${count.index + 3}"
  }
}

resource "aws_subnet" "tf_dbsubnet" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 5)
  availability_zone = count.index % 2 == 0 ? "ap-northeast-2a" : "ap-northeast-2c"
  tags = {
    Name = "${var.pjt_name}_dbsubnet_sn${count.index + 5}"
  }
}
