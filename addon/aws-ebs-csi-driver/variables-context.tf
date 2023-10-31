variable "context" {
  type = object({
    region           = string # describe default region to create a resource from aws
    region_alias     = string #
    project          = string # project name is usally account's project name or platform name
    environment      = string # Runtime Environment such as develop, stage, production
    env_alias        = string #
    owner            = string # project owner
    team             = string # Team name of Devops Transformation
    domain           = string # public toolchain domain name (ex, tools.customer.co.kr)
    pri_domain       = string # private domain name (ex, tools.customer.co.kr)
    name_prefix      = string #
    name_prefix_role = string #
    tags = map(string)
  })
}

variable "irsa_config" {
  type        = any
  description = <<EOF
{
    iam_role_name                = string # IAM role name for IRSA
    iam_policies_arn             = list(string) # IAM Policies for IRSA IAM role
    iam_role_path                = string # IAM role path for IRSA roles
    iam_permissions_boundary     = string # IAM permissions boundary for IRSA roles
    cluster_oidc_provider_arn    = string # EKS OIDC Provider ARN (ex: arn:aws:iam::111122223333:oidc-provider/1124124)
    create_service_account_token = bool
  }
EOF
  default     = {
    iam_role_path                = "/"
    iam_permissions_boundary     = ""
    create_service_account_token = false
  }
}
