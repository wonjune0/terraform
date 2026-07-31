output "pri_rt_ids" {
  value = aws_route_table.tf_pri_rt[*].id
}
