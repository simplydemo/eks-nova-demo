module "ctx" {
  source = "../context/"
}

module "vpc" {
  source               = "git::https://github.com/chiwooiac/tfmodule-aws-vpc.git"
  context              = module.ctx.context
  cidr                 = "10.76.0.0/16"
  azs                  = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[2]]
  public_subnets       = ["10.76.11.0/24", "10.76.12.0/24"]
  public_subnet_names  = ["pub-c1", "pub-c1"]
  public_subnet_suffix = "pub"
  public_subnet_tags   = {
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_pri_domain  = true

  private_subnets = [
    "10.76.41.0/24", "10.76.42.0/24",
    "10.76.51.0/24", "10.76.52.0/24",
  ]
  private_subnet_names = [
    "pri-a1", "pri-c1",
    "etl-a1", "etl-c1",
  ]

  eks_subnets = [
    "10.76.110.0/24", "10.76.111.0/24",
    "10.76.112.0/24", "10.76.113.0/24",
    "10.76.120.0/24", "10.76.121.0/24",
    "10.76.122.0/24", "10.76.123.0/24",
  ]
  eks_subnet_names = [
    "eksmdapp-a1", "eksmdapp-c1",
    "eksarapp-a2", "eksarapp-c2",
    "eksproc-a1", "eksproc-c1",
    "eksproc-a2", "eksproc-c2",
  ]
  eks_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  database_subnets             = ["10.76.91.0/24", "10.76.92.0/24"]
  database_subnet_names        = ["data-a1", "data-c1"]
  database_subnet_suffix       = "data"
  create_database_subnet_group = false
}

