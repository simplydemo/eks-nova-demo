variable "eks_context" {
  type = object({
    region                 = string # describe default region to create a resource from aws
    region_alias           = string #
    project                = string # project name is usally account's project name or platform name
    environment            = string # Runtime Environment such as develop, stage, production
    env_alias              = string #
    owner                  = string # project owner
    team                   = string # Team name of Devops Transformation
    domain                 = string # public toolchain domain name (ex, tools.customer.co.kr)
    pri_domain             = string # private domain name (ex, tools.customer.co.kr)
    name_prefix            = string #
    tags                   = map(string)
    # EKS
    cluster_name           = string
    cluster_simple_name    = string
    cluster_endpoint       = string
    cluster_auth_base64    = string
    service_ipv4_cidr      = string
    node_security_group_id = string
  })
}
