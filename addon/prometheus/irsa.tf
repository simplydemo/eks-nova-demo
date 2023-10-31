locals {
  ingest_role_name   = format("%s%s", local.project, replace(title( format("%s-AmpIngestIRSARole", local.name) ), "-", "" ))
  ingest_policy_name = format("%s%s", local.project, replace(title( format("%s-AmpIngestIRSAPolicy", local.name) ), "-", "" ))
  query_role_name    = format("%s%s", local.project, replace(title( format("%s-AmpQueryIRSARole", local.name) ), "-", "" ))
  query_policy_name  = format("%s%s", local.project, replace(title( format("%s-AmpQueryIRSAPolicy", local.name) ), "-", "" ))
}

# ------------------------------------------
# AMP Ingest Permissions
# ------------------------------------------
data "aws_iam_policy_document" "ingest" {
  statement {
    effect    = "Allow"
    resources = [
      "arn:aws:aps:${local.region_name}:${local.account_id}:workspace/*",
      "arn:aws:aps:${local.region_name}:${local.account_id}:workspace/*/*",
    ]

    actions = [
      "aps:ListWorkspaces",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
      "aps:GetSeries",
      "aps:RemoteWrite",
    ]
  }
}

resource "aws_iam_policy" "ingest" {
  count = var.enable_amazon_prometheus ? 1 : 0

  name        = local.ingest_policy_name
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = merge( local.tags, var.tags,
    {
      Name = local.ingest_policy_name
    }
  )
}

module "AmpIngest" {
  source = "../../modules/irsa"

  create_kubernetes_namespace       = false
  create_kubernetes_service_account = true
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = local.ingest_service_account
  iam_role_name                     = local.ingest_role_name
  iam_policies_arn                  = [try(aws_iam_policy.ingest[0].arn, "")]
  cluster_name                      = var.cluster_name
  cluster_oidc_provider_arn         = var.irsa_config.cluster_oidc_provider_arn

  depends_on = [
    kubernetes_namespace_v1.prometheus
  ]
}


# ------------------------------------------
# AMP Query Permissions
# ------------------------------------------

data "aws_iam_policy_document" "query" {
  statement {
    effect    = "Allow"
    resources = [
      "arn:aws:aps:${local.region_name}:${local.account_id}:workspace/*",
      "arn:aws:aps:${local.region_name}:${local.account_id}:workspace/*/*",
    ]

    actions = [
      "aps:ListWorkspaces",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
      "aps:GetSeries",
      "aps:QueryMetrics",
    ]
  }
}

resource "aws_iam_policy" "query" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = local.query_policy_name
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  policy      = data.aws_iam_policy_document.query.json
  tags        = merge(local.tags, {
    Name = local.query_policy_name
  })
}

module "AmpQuery" {
  source = "../../modules/irsa"

  count = var.enable_amazon_prometheus ? 1 : 0

  create_kubernetes_namespace = false
  kubernetes_namespace        = local.namespace

  kubernetes_service_account = "amp-query"
  iam_role_name              = local.query_role_name
  iam_policies_arn           = [aws_iam_policy.query[0].arn]
  iam_role_path              = "/"
  iam_permissions_boundary   = ""
  cluster_name               = var.cluster_name
  cluster_oidc_provider_arn  = var.irsa_config.cluster_oidc_provider_arn
}
