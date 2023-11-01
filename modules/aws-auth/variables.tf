variable "create" {
  type    = bool
  default = true
}

variable "aws_auth_node_roles" {
  type    = list(string)
  default = []
}

variable "aws_auth_roles" {
  description = <<EOF
List of IAM role maps to add to the aws-auth configmap

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::111122223333:role/EksNodeRole"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes"
      ]
    },
    {
      rolearn  = "arn:aws:iam::111122223333:role/synokesuns"
      username = "synokesuns:{{SessionName}}"
      groups   = ["system:masters"]
    },
  ]

EOF

  type    = list(any)
  default = []
}

variable "aws_auth_users" {
  description = <<EOF
List of user maps to add to the aws-auth configmap

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

EOF

  type    = list(any)
  default = []
}

variable "aws_auth_accounts" {
  description = <<EOF
List of account maps to add to the aws-auth configmap

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
 ]
EOF

  type    = list(string)
  default = []
}
