/*
module "auth" {
  source = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/aws-auth?ref=feature/LT101"

  aws_auth_node_roles = compact([
    module.amd64.node_role_arn,
    module.arm64.node_role_arn,
    module.amd64md.node_role_arn,
    module.arm64md.node_role_arn
  ])

  aws_auth_roles = [
    {
      rolearn  = module.eks.admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/alice.manager@symplesims.io"
      username = "alice"
      groups   = ["system:masters"]
    },
  ]

  depends_on = [
    module.eks,
  ]
}

output "aws_auth_configmap_data" {
  value = module.auth.aws_auth_configmap_data
}
*/