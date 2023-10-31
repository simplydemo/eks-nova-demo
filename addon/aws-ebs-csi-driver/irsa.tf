# AWS Managed IRSA
module "irsaAws" {
  source                            = "../../modules/irsa/"
  count                             = local.create_irsa && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = var.namespace
  kubernetes_service_account        = var.service_account
  cluster_name                      = var.cluster_name
  cluster_oidc_provider_arn         = var.irsa_config.cluster_oidc_provider_arn
  iam_role_name                     = local.iam_role_name
  iam_policies_arn                  = [data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn]
}

# Self Managed IRSA
module "irsaSelf" {
  source                              = "../../modules/irsa/"
  count                               = var.enable_self_managed_aws_ebs_csi_driver && !var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  cluster_name                        = var.cluster_name
  create_kubernetes_namespace         = false
  create_kubernetes_service_account   = true
  create_service_account_secret_token = try(var.irsa_config.create_service_account_token, false)
  kubernetes_service_account          = var.service_account
  kubernetes_namespace                = var.namespace
  cluster_oidc_provider_arn           = var.irsa_config.cluster_oidc_provider_arn
  iam_role_name                       = local.iam_role_name
  iam_policies_arn                    = [data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn]
}