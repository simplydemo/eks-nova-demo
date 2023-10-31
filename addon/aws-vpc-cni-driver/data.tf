data "aws_eks_addon_version" "this" {
  count              = local.get_addon_version ? 1 : 0
  addon_name         = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = var.cluster_version
  most_recent        = var.most_recent
}

data "aws_iam_policy_document" "ipv6" {
  count = var.enable_ipv6 ? 1 : 0
  statement {
    sid     = "IpV6"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CreateTags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
  }
}

