terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }


    #    docker = {
    #      source  = "kreuzwerker/docker"
    #      version = "= 3.0.2"
    #    }
  }

}

provider "aws" {
  region = "ap-northeast-2"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

#provider "bcrypt" {}

/*
provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = local.container_image
    username = data.aws_ecr_authorization_token.ecr.user_name
    password = data.aws_ecr_authorization_token.ecr.password
  }

}
*/