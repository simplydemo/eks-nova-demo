locals {
  project             = var.eks_context.project
  name_prefix         = var.eks_context.name_prefix
  tags                = var.eks_context.tags
  cluster_name        = var.eks_context.cluster_name
  cluster_simple_name = var.eks_context.cluster_simple_name
  node_group_name     = format("%s-%s-%s", local.name_prefix, local.cluster_simple_name, var.name)
  create_node_role    = var.create && var.node_role_arn == null ? true : false
  node_role_arn       = local.create_node_role ? aws_iam_role.node[0].arn : var.node_role_arn
  name_prefix_iam     = format("%s%s%s", local.project, title(local.cluster_simple_name), title(var.name))

  launch_template_id      = var.create_launch_template ? try(aws_launch_template.this[0].id, null) : var.launch_template_id
  # Change order to allow users to set version priority before using defaults
  launch_template_version = coalesce(var.launch_template_version, try(aws_launch_template.this[0].default_version, "$Default"))
}

resource "aws_eks_node_group" "this" {
  count           = var.create ? 1 : 0
  cluster_name    = local.cluster_name
  node_group_name = local.node_group_name
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
  ami_type        = var.ami_id != "" ? null : var.ami_type
  release_version = var.ami_id != "" ? null : var.ami_release_version
  version         = var.ami_id != "" ? null : var.cluster_version

  capacity_type        = var.capacity_type
  disk_size            = var.use_custom_launch_template ? null : var.disk_size
  # if using a custom LT, set disk size on custom LT or else it will error here
  force_update_version = var.force_update_version
  instance_types       = var.instance_types
  labels               = var.labels

  dynamic "launch_template" {
    for_each = var.use_custom_launch_template ? [1] : []

    content {
      id      = local.launch_template_id
      version = local.launch_template_version
    }
  }

  dynamic "remote_access" {
    for_each = length(var.remote_access) > 0 ? [var.remote_access] : []

    content {
      ec2_ssh_key               = try(remote_access.value.ec2_ssh_key, null)
      source_security_group_ids = try(remote_access.value.source_security_group_ids, [])
    }
  }

  dynamic "taint" {
    for_each = var.taints

    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = length(var.update_config) > 0 ? [var.update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
      scaling_config[0].desired_size,
    ]
  }

  tags = merge(local.tags, { Name = local.node_group_name })
}
