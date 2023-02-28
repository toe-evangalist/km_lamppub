# Primarily the AWS provider will be used - I've added in the Prisma Cloud provider as a possiblility for the future

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}