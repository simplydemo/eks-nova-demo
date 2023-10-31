output "node_role_arn" {
  value = try(aws_iam_role.node[0].arn, "")
}
