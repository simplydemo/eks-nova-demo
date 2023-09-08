data "aws_availability_zones" "available" {}

#data "aws_eks_cluster_auth" "this" {
#  name = module.eks.cluster_name
#}

# data "aws_ecr_authorization_token" "ecr" {}

data "aws_vpc" "this" {
  default = false
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}

# Subnets
data "aws_subnets" "eks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-eks*", local.name_prefix)]
  }
}

# subnet_ids                   = data.aws_subnets.eksapp.ids


#eks_subnets = [
#  "10.76.110.0/24", "10.76.111.0/24",
#  "10.76.112.0/24", "10.76.113.0/24",
#  "10.76.120.0/24", "10.76.121.0/24",
#  "10.76.122.0/24", "10.76.123.0/24",
#]
#eks_subnet_names = [
#  "eksapp-a1", "eksapp-c1",
#  "eksapp-a2", "eksapp-c2",
#  "eksproc-a1", "eksproc-c1",
#  "eksproc-a2", "eksproc-c2",
#]
