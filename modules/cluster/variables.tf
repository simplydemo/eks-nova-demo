#
#variable "prefix_separator" {
#  description = "The separator to use between the prefix and the generated timestamp for resource names"
#  type        = string
#  default     = "-"
#}

################################################################################
# Cluster
################################################################################

variable "create" {
  type    = bool
  default = true
}

variable "cluster_name" {
  description = "Simple name of the EKS cluster"
  type        = string
}

variable "cluster_fullname" {
  description = "Fullname of the EKS cluster"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = <<EOF
A list of the desired control plane logs to enable.
For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
Support values are [api, audit, authenticator, controllerManager, scheduler]
EOF
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}


################################################################################
# VPC and Subnets
################################################################################

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled. Default is false."
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled. Default is true."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. Default is `0.0.0.0/0`"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane."
  type        = list(string)
  default     = []
}


################################################################################
# Kubernetes Network Configuration
################################################################################

variable "ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` and `ipv6`. Default is `ipv4`"
  type        = string
  default     = "ipv4"
}

variable "service_ipv4_cidr" {
  description = <<EOF
The CIDR block to assign Kubernetes service IP addresses from.
Be careful not to overlap other VPC CIDRs in your VPC connection.
Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks
EOF

  type    = string
  default = "172.20.0.0/16"
}

variable "service_ipv6_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from if `ipv6` was specified when the cluster was created. Kubernetes assigns service addresses from the unique local address range (fc00::/7) because you can't specify a custom IPv6 CIDR block when you create the cluster"
  type        = string
  default     = null
}

################################################################################
# Outpost Configuration
################################################################################

variable "outpost_config" {
  description = <<EOF
Configuration for the AWS Outpost to provision the cluster on

outpost_config = {
  control_plane_instance_type = "m5.large"
  outpost_arns                = ["arn:aws:outposts:ap-northeast-2:123456789012:outpost/op-12345678901234567"]
  control_plane_placement {
    group_name = "my-outpost-group"
  }
}
EOF

  type    = any
  default = {}
}

################################################################################
# Encryption Configuration
################################################################################

variable "encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default     = {
    resources = ["secrets"]
  }
}

variable "kms_key_arn" {
  description = "ARN of the Key Management Service (KMS) customer master key (CMK)."
  type        = string
  default     = null
}

variable "cluster_timeouts" {
  description = <<EOF
Create, update, and delete timeout configurations for the cluster

cluster_timeouts = {
  create = "60m"
  update = "60m"
  delete = "60m"
}
EOF

  type    = map(string)
  default = {}
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}


################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

################################################################################
# EKS IPV6 CNI Policy
################################################################################

variable "create_cni_ipv6_iam_policy" {
  description = "Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy)"
  type        = bool
  default     = false
}

################################################################################
# IRSA
################################################################################

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

variable "custom_oidc_thumbprints" {
  description = "Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = list(string)
  default     = []
}

################################################################################
# EKS Identity Provider
################################################################################

variable "cluster_identity_providers" {
  description = <<EOF
Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA

  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }

    keycloak = {
      client_id                     = "<keycloak_client_id>"
      identity_provider_config_name = "Keycloak"
      issuer_url                    = "https://<keycloak_url>/auth/realms/<realm_name>"
      groups_claim                  = "groups"
    }
  }

EOF

  type    = any
  default = {}
  #  default = {
  #    sts = {
  #      client_id = "sts.amazonaws.com"
  #    }
  #  }
}

variable "dataplane_wait_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed nodegroup(s), self-managed nodegroup(s), Fargate profile(s))"
  type        = string
  default     = "30s"
}

################################################################################
# Cluster IAM Role
################################################################################
variable "create_eks_admin_role" {
  description = "Determines whether to create an EKS Administrator IAM role for managing the EKS cluster"
  type        = bool
  default     = true
}

variable "cluster_role_arn" {
  description = <<EOF
Existing IAM role ARN for the cluster.
see - https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
EOF
  type        = string
  default     = null
}

variable "cluster_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "cluster_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "cluster_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "cluster_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "cluster_role_additional_policies" {
  description = <<EOF
Additional policies to be added to the IAM role

cluster_role_additional_policies = {
  AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  AmazonEKSVPCResourceController     = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

EOF

  type    = map(string)
  default = {}
}

variable "cluster_policy_path" {
  description = "Cluster IAM policy path"
  type        = string
  default     = null
}

variable "cluster_encryption_policy_description" {
  description = "Description of the encryption policy"
  type        = string
  default     = null
}

################################################################################
# Node Security Group
################################################################################
variable "enabled_node_security_group_rules" {
  description = <<EOF
Determines whether to enable recommended security group rules for the node security group created.
This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic
EOF
  type        = bool
  default     = true
}

variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created"
  type        = string
  default     = ""
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "node_security_group_description" {
  description = "Description of the node security group created"
  type        = string
  default     = "EKS node shared security group"
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_enable_recommended_rules" {
  description = "Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic"
  type        = bool
  default     = true
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}
