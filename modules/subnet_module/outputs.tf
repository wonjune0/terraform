output "pubsubnet_ids_map" {
  value = { for k, s in aws_subnet.tf_pubsubnet : s.availability_zone => s.id }
}
output "pubsubnet_ids_list" {
  value = [for s in aws_subnet.tf_pubsubnet : s.id]
}

output "prisubnet_ids_map" {
  value = { for k, s in aws_subnet.tf_prisubnet : s.availability_zone => s.id }
}

output "prisubnet_ids_list" {
  value = [for s in aws_subnet.tf_prisubnet : s.id]
}

output "dbsubnet_ids" {
  value = [for s in aws_subnet.tf_dbsubnet : s.id]
}
