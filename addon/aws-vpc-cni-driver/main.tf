# see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
locals {
  project           = var.context.project
  name_prefix       = var.context.name_prefix
  name_prefix_role  = var.context.name_prefix_role
  region_name       = var.context.region
  tags              = var.context.tags
  name              = "vpc-cni"
  get_addon_version = var.addon_version == null ? true : false
  addon_version     = var.addon_version == null ? data.aws_eks_addon_version.this[0].version : var.addon_version

  # IRSA
  create_irsa               = var.service_account_role_arn == null ? true : false
  iam_role_name             = try(var.irsa_config.iam_role_name, format("%s%sVpcCniDriverIrsaRole", local.name_prefix_role, title(var.cluster_simple_name)))
  iam_policy_name           = try(var.irsa_config.iam_policy_name, format("%s%sVpcCniDriverIrsaPolicy", local.name_prefix_role, title(var.cluster_simple_name)))
  cluster_oidc_provider_arn = try(var.irsa_config.cluster_oidc_provider_arn, "")
}

resource "aws_eks_addon" "this" {
  cluster_name                = var.cluster_name
  addon_name                  = local.name
  addon_version               = local.addon_version
  #
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
  service_account_role_arn    = local.create_irsa ? module.irsa[0].irsa_iam_role_arn : var.service_account_role_arn
  configuration_values        = var.configuration_values
  preserve                    = var.preserve

  tags = merge(
    var.tags, {
      Name                     = format("%s-%s", var.cluster_name, local.name)
      CreateRisa               = local.create_irsa
      service_account_role_arn = var.service_account_role_arn
    })

}
