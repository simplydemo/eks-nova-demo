/*
################################################################################
# EKS Identity Provider
# Note - this is different from IRSA
################################################################################

resource "aws_eks_identity_provider_config" "this" {
  for_each = {
    for k, v in var.cluster_identity_providers : k => v
    if length(var.cluster_identity_providers) > 0 && !local.enabled_outpost
  }

  cluster_name = aws_eks_cluster.this.name

  oidc {
    client_id                     = each.value.client_id
    groups_claim                  = lookup(each.value, "groups_claim", null)
    groups_prefix                 = lookup(each.value, "groups_prefix", null)
    identity_provider_config_name = try(each.value.identity_provider_config_name, each.key)
    issuer_url                    = try(each.value.issuer_url, local.oidc_issuer)
    required_claims               = lookup(each.value, "required_claims", null)
    username_claim                = lookup(each.value, "username_claim", null)
    username_prefix               = lookup(each.value, "username_prefix", null)
  }

  tags = local.tags
}

*/