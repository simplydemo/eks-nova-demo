module "ctx" {
  source  = "git::https://github.com/chiwooiac/tfmodule-context.git"
  context = {
    region      = "ap-northeast-2"
    project     = "nova"
    environment = "Development"
    owner       = "owener@symplesims.github.io"
    team        = "DevOps"
    domain      = "opencaffes.com"
    pri_domain  = "backend.local"
  }
}

locals {
  cluster_name     = "demo"
  cluster_version  = "1.25" # 1.25 ~ 1.28
  name_prefix_role = format("%s%s", module.ctx.project, title(local.cluster_name))
}