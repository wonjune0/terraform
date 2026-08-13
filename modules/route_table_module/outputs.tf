output "pri_rt_ids" {
  value = [for rt in aws_route_table.tf_pri_rt : rt.id]
}
