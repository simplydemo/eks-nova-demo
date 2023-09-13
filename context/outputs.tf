output "context" {
  value = module.ctx.context
}

output "tags" {
  value = module.ctx.tags
}

output "name_prefix" {
  value = module.ctx.name_prefix
}

output "project" {
  value = module.ctx.project
}

output "cluster_name" {
  value = local.cluster_name
}
output "cluster_version" {
  value = local.cluster_version
}