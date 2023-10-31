data "aws_caller_identity" "current" {
}

data "aws_eks_cluster" "this" {
  name = "${module.ctx.name_prefix}-${module.ctx.cluster_name}-eks"
}

data "aws_iam_openid_connect_provider" "this" {
  url = local.cluster_oidc_issuer_url
}
