locals {
  iam_role_name       = var.iam_role_name !=null ? var.iam_role_name : format("%s-%s-irsa-role", var.cluster_name, trim(var.kubernetes_service_account, "-*"))
  eks_oidc_issuer_url = replace(var.cluster_oidc_provider_arn, "/^(.*provider/)/", "")
}

resource "kubernetes_namespace_v1" "irsa" {
  count = var.create_kubernetes_namespace && var.kubernetes_namespace != "kube-system" ? 1 : 0
  metadata {
    name = var.kubernetes_namespace
  }

  timeouts {
    delete = "15m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_secret_v1" "irsa" {
  count = var.create_kubernetes_service_account && var.create_service_account_secret_token ? 1 : 0
  metadata {
    name        = format("%s-token-secret", try(kubernetes_service_account_v1.irsa[0].metadata[0].name, var.kubernetes_service_account))
    namespace   = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    annotations = {
      "kubernetes.io/service-account.name"      = try(kubernetes_service_account_v1.irsa[0].metadata[0].name, var.kubernetes_service_account)
      "kubernetes.io/service-account.namespace" = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account_v1" "irsa" {
  count = var.create_kubernetes_service_account ? 1 : 0
  metadata {
    name        = var.kubernetes_service_account
    namespace   = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.irsa.arn
    }
  }

  dynamic "image_pull_secret" {
    for_each = var.kubernetes_svc_image_pull_secrets != null ? var.kubernetes_svc_image_pull_secrets : []
    content {
      name = image_pull_secret.value
    }
  }

  automount_service_account_token = true
}


# NOTE: Don't change the condition from StringLike to StringEquals. We are using wild characters for service account hence StringLike is required.
resource "aws_iam_role" "irsa" {
  name               = local.iam_role_name
  description        = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.cluster_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${local.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}",
            "${local.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  path                  = var.iam_role_path
  force_detach_policies = true
  permissions_boundary  = var.iam_permissions_boundary

  tags = merge(var.tags, {
    Name = local.iam_role_name
  })

}

resource "aws_iam_role_policy_attachment" "irsaAws" {
  count      = var.iam_policies_arn != null ? length(var.iam_policies_arn) : 0
  policy_arn = var.iam_policies_arn[count.index]
  role       = aws_iam_role.irsa.name
}
