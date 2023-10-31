locals {
  create_cluster_role           = var.cluster_role_arn == null ? true : false
  cluster_role_arn              = local.create_cluster_role ?  aws_iam_role.cluster[0].arn : var.cluster_role_arn
  name_prefix_iam               = format("%s%s", local.project, title(var.cluster_name))
  cluster_role_name             = format("%sEksClusterRole", local.name_prefix_iam)
  cluster_role_description      = var.cluster_role_description != null ? var.cluster_role_description : format("IAM policy for %s ClusterRole", local.cluster_name)
  cloudwatch_policy_name        = format("%sEksCloudwatchPolicy", local.name_prefix_iam)
  encryption_policy_name        = format("%sEksEncryptionPolicy", local.name_prefix_iam)
  encryption_policy_description = var.cluster_encryption_policy_description != null ? var.cluster_encryption_policy_description : format("IAM encryption policy for %s ClusterRole", local.cluster_name)
  admin_role_name               = format("%sEKSAdminRole", local.name_prefix_iam)
}

data "aws_iam_policy_document" "eksRole" {
  count = local.create_cluster_role ? 1 : 0

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  count                 = local.create_cluster_role ? 1 : 0
  name                  = local.cluster_role_name
  path                  = var.cluster_role_path
  description           = var.cluster_role_description
  assume_role_policy    = data.aws_iam_policy_document.eksRole[0].json
  permissions_boundary  = var.cluster_role_permissions_boundary
  force_detach_policies = true

  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/920
  # Resources running on the cluster are still generating logs when destroying the module resources
  # which results in the log group being re-created even after Terraform destroys it. Removing the
  # ability for the cluster role to create the log group prevents this log group from being re-created
  # outside of Terraform due to services still generating logs during destroy process
  dynamic "inline_policy" {
    for_each = var.create_cloudwatch_log_group ? [1] : []
    content {
      name = local.cloudwatch_policy_name

      policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [
          {
            Action   = ["logs:CreateLogGroup"]
            Effect   = "Deny"
            Resource = "*"
          },
        ]
      })
    }
  }

  tags = merge(local.tags, var.cluster_role_tags)
}


# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "cluster" {
  count      = local.create_cluster_role && !local.enabled_outpost ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "outpost" {
  count      = local.create_cluster_role && local.enabled_outpost ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLocalOutpostClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "rsCtrl" {
  count      = local.create_cluster_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = {
    for k, v in var.cluster_role_additional_policies : k => v if local.create_cluster_role
  }
  policy_arn = each.value
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_policy" "encryption" {
  # Encryption config not available on Outposts
  count       = local.create_cluster_role && local.enabled_encryption_config? 1 : 0
  name        = local.encryption_policy_name
  name_prefix = null
  description = var.cluster_encryption_policy_description
  path        = var.cluster_policy_path

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = var.kms_key_arn
      },
    ]
  })

  tags = merge(local.tags, { Name = local.encryption_policy_name })
}

# Using separate attachment due to `The "for_each" value depends on resource attributes that cannot be determined until apply`
resource "aws_iam_role_policy_attachment" "encryption" {
  # Encryption config not available on Outposts
  count      = local.create_cluster_role && local.enabled_encryption_config? 1 : 0
  policy_arn = aws_iam_policy.encryption[0].arn
  role       = aws_iam_role.cluster[0].name
}


################################################################################
# EKS IPV6 CNI Policy
# XXX - hopefully AWS releases a managed policy which can replace this
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
################################################################################

data "aws_iam_policy_document" "ipv6" {
  count = local.ipv6 && var.create_cni_ipv6_iam_policy ? 1 : 0

  statement {
    sid     = "AssignDescribe"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CreateTags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
  }
}

# Note - we are keeping this to a minimum in hopes that its soon replaced with an AWS managed policy like `AmazonEKS_CNI_Policy`
resource "aws_iam_policy" "ipv6" {
  count = local.ipv6 && var.create_cni_ipv6_iam_policy ? 1 : 0

  # Will cause conflicts if trying to create on multiple clusters but necessary to reference by exact name in sub-modules
  name        = "AmazonEKS_CNI_IPv6_Policy"
  description = "IAM policy for EKS CNI to assign IPV6 addresses"
  policy      = data.aws_iam_policy_document.ipv6[0].json
  tags        = local.tags
}


################################################################################
# Create EKS Administrator IAM Role and policy
################################################################################

data "aws_iam_policy_document" "admin" {
  count = local.create_cluster_role ? 1 : 0

  statement {
    sid     = "EKSClusterAdminAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "admin" {
  count              = var.create_eks_admin_role ? 1 : 0
  name               = local.admin_role_name
  path               = var.cluster_role_path
  description        = var.cluster_role_description
  assume_role_policy = data.aws_iam_policy_document.admin[0].json

  tags = merge(local.tags, { Name = local.admin_role_name })

  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count      = var.create_eks_admin_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.admin[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  count      = var.create_eks_admin_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.admin[0].name
}

resource "aws_iam_role_policy" "admin" {
  count  = var.create_eks_admin_role ? 1 : 0
  name   = format("%sEKSAdminPolicy", local.name_prefix_iam)
  role   = aws_iam_role.admin[0].name
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSClusterReadRole"
        Effect = "Allow"
        Action = [
          "eks:DescribeFargateProfile",
          "eks:DescribeAddonConfiguration",
          "eks:DescribeAddon",
          "eks:DescribeNodegroup",
          "eks:DescribeIdentityProviderConfig",
          "eks:DescribeUpdate",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:ListClusters",
          "eks:ListAddons",
          "eks:ListUpdates",
          "eks:ListNodegroups",
          "eks:ListTagsForResource",
          "eks:ListFargateProfiles",
          "eks:ListIdentityProviderConfigs"
        ]
        Resource = ["*"]
      },
    ]
  })
}
