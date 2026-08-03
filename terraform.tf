terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
