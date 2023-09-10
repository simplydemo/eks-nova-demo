module "ctx" {
  source = "../context/"
}

locals {
  project        = module.ctx.project
  name_prefix    = module.ctx.name_prefix
  tags           = module.ctx.tags
  cluster_name   = "demo"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "prometheus"
  version    = "1.27"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
}

#helm upgrade -i prometheus prometheus-community/prometheus \
#--namespace prometheus \
#--set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"