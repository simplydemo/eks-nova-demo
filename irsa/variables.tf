variable "kubernetes_namespace" {
  description = "Kubernetes Namespace name"
  type        = string
}

variable "create_kubernetes_namespace" {
  description = "Should the module create the namespace"
  type        = bool
  default     = true
}

variable "create_kubernetes_service_account" {
  description = "Should the module create the Service Account"
  type        = bool
  default     = true
}

variable "create_service_account_secret_token" {
  description = "Should the module create a secret for the service account (from k8s version 1.24 service account doesn't automatically create secret of the token)"
  type        = bool
  default     = false
}

variable "kubernetes_service_account" {
  description = "Kubernetes Service Account Name"
  type        = string
}

variable "kubernetes_svc_image_pull_secrets" {
  description = "list(string) of kubernetes imagePullSecrets"
  type        = list(string)
  default     = []
}

# IRSA
variable "iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = null
}

variable "iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "iam_policies_arn" {
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN e.g., arn:aws:iam::<ACCOUNT-ID>:oidc-provider/<var.eks_oidc_provider>"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
