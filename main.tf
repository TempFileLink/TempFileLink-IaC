terraform {
  cloud {
    organization = "kowan123"

    workspaces {
      name = "Production"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.credentials.access_key
  secret_key = var.credentials.secret_key
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "production"
    project     = "kowan"
  }
}
