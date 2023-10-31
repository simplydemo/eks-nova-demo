locals {
  sg_primary_name           = format("%s-sg", local.cluster_name)
  sg_cluster_name           = format("%s-cluster-sg", local.cluster_name)
  sg_node_name              = format("%s-node-sg", local.cluster_name)
  cluster_security_group_id = try(aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id, null)
}

################################################################################
# Cluster Security Group
################################################################################
resource "aws_ec2_tag" "sg_primary" {
  for_each = {
    for k, v in merge(local.tags, var.cluster_tags, { Name = local.sg_primary_name }) :
    k => v if v != null
  }

  resource_id = try(aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id, null)
  key         = each.key
  value       = each.value
}

resource "aws_security_group" "cluster" {
  name        = local.sg_cluster_name
  description = local.sg_cluster_name
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { Name = local.sg_cluster_name })
}

resource "aws_security_group_rule" "inC443" {
  description              = "Node groups to cluster API"
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
}


################################################################################
# Worker Node Security Group
################################################################################

resource "aws_security_group" "node" {
  name        = local.sg_node_name
  name_prefix = null
  description = var.node_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.node_security_group_tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    },
    {
      Name = local.sg_node_name
    },
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
      # tags_all,
    ]
  }
}

resource "aws_security_group_rule" "inN443" {
  description              = "Cluster API to node groups"
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
}

resource "aws_security_group_rule" "inN10250" {
  description              = "Cluster API to node kubelets"
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10250
}

#resource "aws_security_group_rule" "inN53" {
#  description       = "Node to node CoreDNS"
#  type              = "ingress"
#  security_group_id = aws_security_group.node.id
#  self              = true
#  protocol          = "tcp"
#  from_port         = 53
#  to_port           = 53
#}
#
#resource "aws_security_group_rule" "inN53UDP" {
#  description       = "Node to node CoreDNS UDP"
#  type              = "ingress"
#  security_group_id = aws_security_group.node.id
#  self              = true
#  protocol          = "udp"
#  from_port         = 53
#  to_port           = 53
#}
#
#resource "aws_security_group_rule" "inNEprl" {
#  count             = var.enabled_node_security_group_rules ? 1 : 0
#  description       = "Node to node ingress on ephemeral ports"
#  type              = "ingress"
#  security_group_id = aws_security_group.node.id
#  self              = true
#  protocol          = "tcp"
#  from_port         = 1025
#  to_port           = 65535
#}

resource "aws_security_group_rule" "inNodes" {
  count             = var.enabled_node_security_group_rules ? 1 : 0
  description       = "Node to node all ports/protocols"
  type              = "ingress"
  security_group_id = aws_security_group.node.id
  self              = true
  protocol          = -1
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "inN4443" {
  count                    = var.enabled_node_security_group_rules ? 1 : 0
  description              = "Cluster API to node 4443/tcp webhook for Metrics Server"
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  protocol                 = "tcp"
  from_port                = 4443
  to_port                  = 4443
}

resource "aws_security_group_rule" "inN6443" {
  count                    = var.enabled_node_security_group_rules ? 1 : 0
  description              = "Cluster API to node 6443/tcp webhook for Prometheus Adapter"
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
}

resource "aws_security_group_rule" "inN8443" {
  count                    = var.enabled_node_security_group_rules ? 1 : 0
  description              = "Cluster API to node 8443/tcp webhook for Karpenter"
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
}

resource "aws_security_group_rule" "inN9443" {
  count                    = var.enabled_node_security_group_rules ? 1 : 0
  description              = "Cluster API to node 9443/tcp webhook for ALB(NGINX) controller"
  type                     = "ingress"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 9443
  to_port                  = 9443
}

resource "aws_security_group_rule" "outNAny" {
  count             = var.enabled_node_security_group_rules ? 1 : 0
  description       = "Allow all egress"
  type              = "egress"
  security_group_id = aws_security_group.node.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = var.ip_family == "ipv6" ? ["::/0"] : null
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
}
