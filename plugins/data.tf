data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = local.cluster_oidc_issuer_url
}

