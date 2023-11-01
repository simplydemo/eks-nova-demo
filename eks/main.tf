module "ctx" {
  source = "../context/"
}

locals {
  project         = module.ctx.project
  name_prefix     = module.ctx.name_prefix
  tags            = module.ctx.tags
  cluster_name    = module.ctx.cluster_name
  cluster_version = module.ctx.cluster_version
  vpc_id          = data.aws_vpc.this.id
  eks_subnet_ids  = data.aws_subnets.eks.ids
}

module "eks" {
  source          = "../modules/cluster/"
  context         = module.ctx.context
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id          = local.vpc_id
  subnet_ids      = local.eks_subnet_ids

  cluster_role_additional_policies = {
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }
}

