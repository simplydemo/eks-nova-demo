locals {

  project            = var.context.project
  name_prefix        = var.context.name_prefix
  region_name        = var.context.region
  tags               = var.context.tags
  name               = "aws-ebs-csi-driver"
  namespace          = var.namespace
  addon_version      = var.addon_version != null ? var.addon_version : (  var.enable_amazon_eks_aws_ebs_csi_driver ? data.aws_eks_addon_version.this.version : replace(data.aws_eks_addon_version.this.version, "/-eksbuild.*/", "")  )
  service_account    = var.service_account
  kubernetes_version = var.kubernetes_version == null? var.cluster_version : var.kubernetes_version

  # IRSA
  create_irsa               = var.service_account_role_arn == null ? true : false
  iam_role_name             = try(var.irsa_config.iam_role_name, format("%s%s", local.project, "EBSCSIDriverIRSARole"))
  iam_policy_name           = try(var.irsa_config.iam_policy_name, format("%s%s", local.project, "EBSCSIDriverIRSAPolicy"))
  cluster_oidc_provider_arn = try(var.irsa_config.cluster_oidc_provider_arn, "")
}

data "aws_eks_addon_version" "this" {
  addon_name         = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = local.kubernetes_version
  most_recent        = var.addon_most_recent
}

# AWS Managed Addon
resource "aws_eks_addon" "addon" {
  count                       = var.enable_amazon_eks_aws_ebs_csi_driver && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0
  cluster_name                = var.cluster_name
  addon_name                  = local.name
  addon_version               = local.addon_version
  resolve_conflicts_on_update = var.addon_resolve_conflicts_on_update
  service_account_role_arn    = local.create_irsa ? module.irsaAws[0].irsa_iam_role_arn : var.service_account_role_arn
  preserve                    = var.addon_preserve
  configuration_values        = var.addon_configuration_values
  tags                        = local.tags
}

# Self Managed
resource "helm_release" "helm" {
  count       = var.enable_self_managed_aws_ebs_csi_driver && !var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  name        = local.name
  description = "The Amazon Elastic Block Store Container Storage Interface (CSI) Driver provides a CSI interface used by Container Orchestrators to manage the lifecycle of Amazon EBS volumes."
  repository  = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart       = local.name
  version     = "2.12.1"
  namespace   = local.namespace
  timeout     = "300"
  values      = [
    <<-EOT
      image:
        repository: public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver
        tag: ${local.addon_version}
      controller:
        k8sTagClusterId: ${var.cluster_name}
      EOT
  ]

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  depends_on = [
    module.irsaAws,
    module.irsaSelf
  ]
}
