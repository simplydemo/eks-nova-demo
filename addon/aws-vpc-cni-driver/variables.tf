#variable "account_id" {
#  type    = string
#}

variable "cluster_name" {
  type    = string
}

variable "cluster_simple_name" {
  type = string
}

variable "cluster_version" {
  type    = string
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "addon_version" {
  type    = string
  default = null
}

variable "most_recent" {
  type    = bool
  default = true
}

variable "preserve" {
  type    = bool
  default = false
}

variable "resolve_conflicts_on_create" {
  type    = string
  default = "OVERWRITE"
}


variable "resolve_conflicts_on_update" {
  type    = string
  default = "OVERWRITE"
}

variable "configuration_values" {
  type    = string
  default = null
}

variable "service_account_role_arn" {
  type    = string
  default = null
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "service_account" {
  type    = string
  default = "aws-node"
}

variable "enable_ipv6" {
  description = "Enable IPV6 CNI policy"
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {}
}
