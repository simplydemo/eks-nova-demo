module "ctx" {
  source = "../context/"
}

locals {
  project                   = module.ctx.project
  name_prefix               = module.ctx.name_prefix
  region_name               = module.ctx.context.region
  tags                      = module.ctx.tags
  account_id                = data.aws_caller_identity.current.account_id
  cluster_simple_name       = module.ctx.cluster_name
  cluster_name              = format("%s-%s-eks", local.name_prefix, local.cluster_simple_name)
  cluster_version           = data.aws_eks_cluster.this.version
  cluster_oidc_issuer_url   = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  cluster_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn # "arn:aws:iam::${local.account_id}:oidc-provider/${local.cluster_oidc_issuer_url}"

  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_amazon_prometheus             = true
}

module "ebsCsiDriver" {
  source                               = "./aws-ebs-csi-driver"
  count                                = local.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  enable_amazon_eks_aws_ebs_csi_driver = true
  context                              = module.ctx.context
  account_id                           = data.aws_caller_identity.current.account_id
  cluster_name                         = data.aws_eks_cluster.this.name
  cluster_version                      = local.cluster_version
  irsa_config                          = {
    cluster_oidc_provider_arn = local.cluster_oidc_provider_arn
  }
}

module "prometheusWS" {
  source          = "terraform-aws-modules/managed-service-prometheus/aws"
  version         = "~> 2.1"
  workspace_alias = format("%s-%s", local.project, local.cluster_simple_name)
  tags            = local.tags
}

module "prometheus" {
  source                   = "./prometheus"
  count                    = local.enable_amazon_prometheus ? 1 : 0
  enable_amazon_prometheus = local.enable_amazon_prometheus
  context                  = module.ctx.context
  account_id               = data.aws_caller_identity.current.account_id
  cluster_name             = data.aws_eks_cluster.this.name
  cluster_version          = local.cluster_version
  amazon_prometheus_workspace_endpoint = module.prometheusWS.workspace_prometheus_endpoint
  irsa_config              = {
    cluster_oidc_provider_arn = local.cluster_oidc_provider_arn
  }
  depends_on = [module.ebsCsiDriver]
}

