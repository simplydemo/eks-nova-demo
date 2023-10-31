output "context" {
  value = merge(module.ctx.context, {
    name_prefix_role = local.name_prefix_role
  })
}

output "tags" {
  value = module.ctx.tags
}

output "name_prefix" {
  value = module.ctx.name_prefix
}

output "name_prefix_role" {
  value = local.name_prefix_role
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