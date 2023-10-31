locals {
  node_role_name = format("%sEksNodeRole", local.name_prefix_iam)
  cni_policy     = var.cluster_ip_family == "ipv6" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy" : "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.create_node_role ? 1 : 0
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "node" {
  count                 = local.create_node_role ? 1 : 0
  name                  = local.node_role_name
  path                  = var.iam_role_path
  description           = var.iam_role_description
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true
  tags                  = merge(local.tags, var.iam_role_tags, { Name = local.node_role_name })
}

# "arn:aws:iam::aws:policy"
# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for k, v in toset(compact([
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      var.iam_role_attach_cni_policy ? local.cni_policy : "",
    ])) : k => v if local.create_node_role
  }

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = {for k, v in var.iam_role_additional_policies : k => v if local.create_node_role}

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}
