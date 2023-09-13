terraform {
  required_version = ">= 1.4.0"

  backend "local" {
    path = "../../tfStates/eks-nova-demo/plugins/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
  }

}

provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.name]
      command     = "aws"
    }
  }
  experiments {
    manifest = true
  }
}