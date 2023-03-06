# Primarily the AWS provider will be used - I've added in the Prisma Cloud provider as a possiblility for the future

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.74.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}