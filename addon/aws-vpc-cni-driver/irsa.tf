resource "aws_iam_policy" "ipv6" {
  count = var.enable_ipv6 ? 1 : 0

  name        = format("%s-%sEksCNIIPv6Policy", var.irsa_config.name_prefix_role)
  description = "IAM policy for EKS CNI to assign IPV6 addresses"
  path        = try(var.irsa_config.irsa_iam_role_path, null)
  policy      = data.aws_iam_policy_document.ipv6[0].json

  tags = merge(
    var.tags, {
      Name = format("%s%sEksCNIIPv6Policy", var.context.name_prefix_role, title(var.cluster_simple_name))
    })
}

# AWS Managed IRSA
module "irsa" {
  source                            = "../../modules/irsa/"
  count                             = local.create_irsa  ? 1 : 0
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = var.namespace
  kubernetes_service_account        = var.service_account
  cluster_name                      = var.cluster_name
  cluster_oidc_provider_arn         = var.irsa_config.cluster_oidc_provider_arn
  iam_role_name                     = local.iam_role_name
  iam_policies_arn                  = compact([
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    try(aws_iam_policy.ipv6[0].arn, null),
    try(var.irsa_config.iam_policies_arn, null)
  ])
  tags = local.tags
}

