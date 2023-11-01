terraform {
  required_version = ">= 1.4.0"

#  backend "local" {
#    path = "../../tfStates/eks-nova-demo/eks/terraform.tfstate"
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    /*


    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    */

    #    docker = {
    #      source  = "kreuzwerker/docker"
    #      version = "= 3.0.2"
    #    }
  }

}

provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}


/*


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
*/

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