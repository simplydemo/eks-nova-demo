module "auth" {
  source = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/aws-auth?ref=feature/LT101"

  aws_auth_roles = [
    {
      rolearn  = module.eks.admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.eks.admin_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/alice.manager@symplesims.io"
      username = "alice"
      groups   = ["system:masters"]
    },
  ]

  depends_on = [module.eks]
}