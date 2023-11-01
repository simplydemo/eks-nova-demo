/*
aws_auth_roles = yamlencode(
  concat(
    var.aws_auth_roles,
    [
      for role_arn in var.aws_auth_node_roles :
      {
        rolearn  = role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes",
        ]
      }
    ]
  )
)
*/

locals {
  exists_aws_auth_roles      = length(var.aws_auth_roles) > 0  ? true : false
  exists_aws_auth_users      = length(var.aws_auth_users) > 0  ? true : false
  exists_aws_auth_account    = length(var.aws_auth_accounts) > 0 ? true : false
  enabled_aws_auth_configmap = var.create # || local.exists_aws_auth_roles || local.exists_aws_auth_users || local.exists_aws_auth_account ? true : false

  map_roles_yaml    = local.exists_aws_auth_roles ? yamlencode(var.aws_auth_roles) : ""
  map_users_yaml    = local.exists_aws_auth_users ? yamlencode(var.aws_auth_users) : ""
  map_accounts_yaml = local.exists_aws_auth_account ? yamlencode(var.aws_auth_accounts) : ""

  aws_auth_configmap_data = {
    mapRoles    = local.map_roles_yaml
    mapUsers    = local.map_users_yaml
    mapAccounts = local.map_accounts_yaml
  }

}


################################################################################
# aws-auth configmap
################################################################################
resource "kubernetes_config_map" "auth" {
  count = local.enabled_aws_auth_configmap ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [
      data,
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}

resource "kubernetes_config_map_v1_data" "auth" {
  count = local.enabled_aws_auth_configmap ? 1 : 0

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = local.map_roles_yaml
    mapUsers    = local.map_users_yaml
    mapAccounts = local.map_accounts_yaml
  }

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.auth,
  ]
}
