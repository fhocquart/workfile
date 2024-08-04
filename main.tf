terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
 region = "ca-central-1"
}

module "FEMI_VPC" {
  source = "./FEMI_VPC"
}
