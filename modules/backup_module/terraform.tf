terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.ap_northeast_3]
      version               = "6.53.0"
    }
  }
}
