terraform {
  required_version = ">= 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
  backend "s3" {
    bucket       = "terraform-state-441250065994-ap-northeast-2-an"
    key          = "seoul/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true

  }
}

locals {
  common_tag = {
    Project   = var.pjt_name
    ManagedBy = "terraform"
  }
}

provider "aws" {
  region = var.region_name

  default_tags {
    tags = local.common_tag
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tag
  }
}

provider "aws" {
  alias  = "ap_northeast_3"
  region = "ap-northeast-3"

  default_tags {
    tags = local.common_tag
  }
}
