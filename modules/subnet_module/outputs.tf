output "pubsubnet_ids" {
  value = aws_subnet.tf_pubsubnet[*].id
}
output "prisubnet_ids" {
  value = aws_subnet.tf_prisubnet[*].id
}
output "dbsubnet_ids" {
  value = aws_subnet.tf_dbsubnet[*].id
}
