module "ctx" {
  source = "../context"
}

locals {
  cluster_name              = data.aws_eks_cluster.this.name
  cluster_version           = data.aws_eks_cluster.this.version
  tags                      = module.ctx.tags
  # for IRSA
  cluster_oidc_issuer_url   = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  cluster_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn

  # addon
  enable_aws_vpc_cni_driver = true
  enable_aws_ebs_csi_driver = true
}

module "vpcCni" {
  source              = "../addon/aws-vpc-cni-driver/"
  count               = local.enable_aws_vpc_cni_driver ? 1 : 0
  cluster_simple_name = module.ctx.cluster_name
  cluster_name        = local.cluster_name
  cluster_version     = local.cluster_version
  context             = module.ctx.context
  irsa_config         = {
    cluster_oidc_provider_arn = local.cluster_oidc_provider_arn
  }
}

module "ebsCsi" {
  source                               = "../addon/aws-ebs-csi-driver/"
  count                                = local.enable_aws_ebs_csi_driver ? 1 : 0
  enable_amazon_eks_aws_ebs_csi_driver = true
  context                              = module.ctx.context
  account_id                           = data.aws_caller_identity.current.account_id
  cluster_name                         = data.aws_eks_cluster.this.name
  cluster_simple_name                  = module.ctx.cluster_name
  cluster_version                      = local.cluster_version
  irsa_config                          = {
    cluster_oidc_provider_arn = local.cluster_oidc_provider_arn
  }
}
