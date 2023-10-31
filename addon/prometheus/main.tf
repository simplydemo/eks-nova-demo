#---------------------------------------
# Prometheus Server Add-on
#---------------------------------------

locals {
  project                = var.context.project
  name_prefix            = var.context.name_prefix
  region_name            = var.context.region
  tags                   = var.context.tags
  name                   = "prometheus"
  cluster_name           = var.cluster_name
  account_id             = var.account_id
  ingest_service_account = "amp-ingest"
  # AWS Managed Prometheus 서비스라면 IRSA 에 해당하는 role arn 필요, default ""
  ingest_iam_role_arn    = var.enable_amazon_prometheus ? module.AmpIngest.irsa_iam_role_arn : ""
  # AWS Managed Prometheus 서비스라면 관련  Workspace Endpoint 설정 필요
  workspace_url          = var.amazon_prometheus_workspace_endpoint != null ? "${var.amazon_prometheus_workspace_endpoint}api/v1/remote_write" : ""
  namespace              = "prometheus"
  service_account        = format("%s-sa", local.name )

  set_values = var.enable_amazon_prometheus ? [
    {
      name  = "serviceAccounts.server.name"
      value = local.ingest_service_account
    },
    {
      name  = "serviceAccounts.server.create"
      value = false
    },
    {
      name  = "serviceAccounts.server.annotations.eks\\.amazonaws\\.com/role-arn"
      value = local.ingest_iam_role_arn
    },
    {
      name  = "server.remoteWrite[0].url"
      value = local.workspace_url
    },
    {
      name  = "server.remoteWrite[0].sigv4.region"
      value = local.region_name
    }
  ] : []
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.namespace
  }
}

# https://github.com/prometheus-community/helm-charts/releases/download/prometheus-15.17.0/prometheus-15.17.0.tgz
resource "helm_release" "prometheus" {
  name         = local.name
  #  helm bug about "could not download chart: Chart.yaml file is missing" so not use repository
  chart        = "https://github.com/prometheus-community/helm-charts/releases/download/prometheus-15.17.0/prometheus-15.17.0.tgz"
  # repository   = "https://prometheus-community.github.io/helm-charts"
  # version      = "15.17.0"
  # chart        = "prometheus"
  namespace    = local.namespace
  #
  lint         = false
  verify       = false
  reset_values = false
  force_update = false
  max_history  = 0
  wait         = true

  values = [
    templatefile("${path.module}/values.yaml", {
      operating_system = "linux"
    })
  ]

  dynamic "set" {
    iterator = each_item
    for_each = local.set_values

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = try(each_item.value.type, null)
    }
  }

  depends_on = [module.AmpIngest]
}
