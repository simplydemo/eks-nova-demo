terraform {
  required_version = ">= 1.4.0"

  backend "local" {
    path = "../../tfStates/eks-nova-demo/vpc/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

  }
}

provider "aws" {
  region  = "ap-northeast-2"
}
