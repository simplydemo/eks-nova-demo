################################################################################
# Cluster
################################################################################

locals {
  cluster_endpoint       = try(aws_eks_cluster.this[0].endpoint, null)
  cluster_auth_base64    = try(aws_eks_cluster.this[0].certificate_authority[0].data, null)
  node_security_group_id = try(aws_security_group.node.id, null)
}

output "context" {
  value = merge(var.context, {
    cluster_name           = local.cluster_name
    cluster_simple_name    = var.cluster_name
    cluster_endpoint       = local.cluster_endpoint
    cluster_auth_base64    = local.cluster_auth_base64
    service_ipv4_cidr      = var.service_ipv4_cidr
    node_security_group_id = local.node_security_group_id
  })
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(aws_eks_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = try(aws_eks_cluster.this[0].id, "")
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.this[0].name, "")
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = local.cluster_auth_base64
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = local.cluster_endpoint
}

output "service_ipv4_cidr" {
  value = var.service_ipv4_cidr
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = local.cluster_oidc_issuer_url
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(aws_eks_cluster.this[0].version, null)
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(aws_eks_cluster.this[0].platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(aws_eks_cluster.this[0].status, null)
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(local.cluster_security_group_id, null)
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = try(aws_security_group.node.arn, null)
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = local.node_security_group_id
}

output "cluster_role_name" {
  value = try(aws_iam_role.cluster[0].name, "")
}

output "cluster_role_arn" {
  value = try(aws_iam_role.cluster[0].arn, "")
}

output "admin_role_arn" {
  value = try(aws_iam_role.admin[0].arn, "")
}
