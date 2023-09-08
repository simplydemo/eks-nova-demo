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