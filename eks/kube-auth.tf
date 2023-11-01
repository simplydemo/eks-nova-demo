module "awsAuth" {
  source = "../modules/aws-auth/"

  aws_auth_roles = concat(
    module.amd64.node_role_arn == "" ? [] : [
      {
        rolearn  = module.amd64.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
    module.arm64.node_role_arn == "" ? [] : [
      {
        rolearn  = module.arm64.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
    module.amd64md.node_role_arn == "" ? [] : [
      {
        rolearn  = module.amd64md.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
    module.arm64md.node_role_arn == "" ? [] : [
      {
        rolearn  = module.arm64md.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
    module.arm64br.node_role_arn == "" ? [] : [
      {
        rolearn  = module.arm64br.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
  )

  depends_on = [
    module.amd64,
    module.arm64,
    module.amd64md,
    module.arm64md,
    module.arm64br
  ]
}

