terraform {
    backend "s3" {
        bucket = "demo-bucket-batak-420"
        key    = "path/to/my/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "demo-table-batak-420"
    }
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}
provider "aws" {
    region = var.region
}