locals {

}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_cloudwatch_log_group ? 1 : 0
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(
    local.tags,
    { Name = "/aws/eks/${local.cluster_name}/cluster" }
  )
}
