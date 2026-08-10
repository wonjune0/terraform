terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
  backend "s3" {
    bucket       = "terrafrom-state-441250065994-ap-northeast-2-an"
    key          = "seoul/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true

  }
}

provider "aws" {
  region = var.region_name
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
