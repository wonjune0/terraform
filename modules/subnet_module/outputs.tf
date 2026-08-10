output "pubsubnet_ids" {
  value = [for s in aws_subnet.tf_pubsubnet : s.id]
}
output "prisubnet_ids" {
  value = [for s in aws_subnet.tf_prisubnet : s.id]
}
output "dbsubnet_ids" {
  value = [for s in aws_subnet.tf_dbsubnet : s.id]
}
