data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "example" {
  bucket        = format("my-tf-test-bucket-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  force_destroy = true
}

