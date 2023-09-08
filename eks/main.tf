module "ctx" {
  source = "../context/"
}

locals {
  project        = module.ctx.project
  name_prefix    = module.ctx.name_prefix
  tags           = module.ctx.tags
  cluster_name   = "demo"
  vpc_id         = data.aws_vpc.this.id
  eks_subnet_ids = data.aws_subnets.eks.ids
}

output "eks_subnet_ids" {
  value = local.eks_subnet_ids
}
module "eks" {
  source       = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git"
  context      = module.ctx.context
  cluster_name = local.cluster_name
  vpc_id       = local.vpc_id
  subnet_ids   = local.eks_subnet_ids

  cluster_role_additional_policies = {
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CustomPolicy                       = aws_iam_policy.custom.arn
  }

  depends_on = [
    aws_iam_policy.custom
  ]
}
