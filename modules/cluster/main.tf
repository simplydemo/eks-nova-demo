locals {
  create                    = var.create
  project                   = var.context.project
  name_prefix               = var.context.name_prefix
  tags                      = var.context.tags
  cluster_name              = var.cluster_fullname != null ? var.cluster_fullname : format("%s-%s-eks", local.name_prefix, var.cluster_name)
  enabled_outpost           = length(var.outpost_config) > 0 ? true : false
  enabled_encryption_config = local.enabled_outpost || var.kms_key_arn == null ? false : true
  ipv6                      = var.ip_family == "ipv4" ? false : true
  enabled_irsa            = var.enable_irsa && !local.enabled_outpost
  cluster_oidc_issuer_url = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, null)
}

################################################################################
# EKS Cluster
################################################################################
resource "aws_eks_cluster" "this" {
  count                     = local.create ? 1 : 0
  name                      = local.cluster_name
  role_arn                  = local.cluster_role_arn
  version                   = var.cluster_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    subnet_ids              = var.subnet_ids
    security_group_ids      = compact(concat(var.security_group_ids, [aws_security_group.cluster.id]))
  }

  dynamic "kubernetes_network_config" {
    for_each = local.enabled_outpost ? [] : [1]
    content {
      ip_family         = var.ip_family
      service_ipv4_cidr = var.service_ipv4_cidr
      service_ipv6_cidr = var.service_ipv6_cidr
    }
  }

  dynamic "outpost_config" {
    for_each = local.enabled_outpost ? [var.outpost_config] : []
    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type
      outpost_arns                = outpost_config.value.outpost_arns
      #      control_plane_placement {
      #        group_name = outpost_config.value.group_name
      #      }
    }
  }

  dynamic "encryption_config" {
    for_each = local.enabled_encryption_config ? ["1"] : []

    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  tags = merge(
    local.tags,
    var.cluster_tags,
  )

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.outpost,
    aws_iam_role_policy_attachment.rsCtrl,
    aws_security_group_rule.inC443,
    aws_security_group_rule.outNAny,
    aws_cloudwatch_log_group.this,
    aws_iam_policy.ipv6,
  ]
}

# Not available on outposts
data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0
  url   = local.cluster_oidc_issuer_url
}

################################################################################
# IRSA (IAM Roles for Service Accounts)
# Note - this is different from EKS identity provider
################################################################################
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count           = local.enabled_irsa ? 1 : 0
  client_id_list  = distinct(compact(concat(["sts.amazonaws.com"], var.openid_connect_audiences)))
  thumbprint_list = concat(data.tls_certificate.this[0].certificates[*].sha1_fingerprint, var.custom_oidc_thumbprints)
  url             = local.cluster_oidc_issuer_url
  tags            = merge(local.tags, { Name = "${local.cluster_name}-irsa" })
}
