resource "aws_ssm_parameter" "tf_cloudfront_distribution_id" {
  name  = "/${var.pjt_name}/frontend/distribution_id"
  type  = "String"
  value = var.cloudfront_distribution_id
}

resource "aws_ssm_parameter" "tf_frontend_bucket_name" {
  name  = "/${var.pjt_name}/frontend/bucket_name"
  type  = "String"
  value = var.frontend_bucket_id
}
