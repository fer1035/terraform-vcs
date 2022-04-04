/* This Terraform configuration serves to demonstrate using multiple predefined
modules from private registries to deploy a complete application without changing
module codes, only specifying inputs and outputs in the process. */

# Account & deployment data.
data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Provider data.
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name       = "VCS Test"
      sitecode   = "123"
      department = "Demolition"
      team       = "myteam@mycompany.com"
      tier       = "dev"
      costcenter = "1234"
    }
  }
}

module "static-website" {
  source = "app.terraform.io/fer1035/static-website/aws"
}

module "cloudfront-invalidator" {
  source         = "app.terraform.io/fer1035/s3-cloudfront-invalidator/aws"
  bucket_name    = module.static-website.s3_bucket_name
  bucket_arn     = module.static-website.s3_bucket_arn
  cloudfront_id  = module.static-website.cloudfront_id
  cloudfront_arn = module.static-website.cloudfront_arn
}

# Outputs.
output "website_url" {
  value       = "https://${module.static-website.cloudfront_domain}"
  description = "The website URL."
}
output "iam_user" {
  value       = module.static-website.iam_user
  description = "The IAM user with upload access to the website S3 bucket."
}
output "iam_credentials_cli" {
  value       = "aws iam create-access-key --user-name ${module.static-website.iam_user} --profile <your_CLI_profile>"
  description = "The AWSCLI command to generate access key credentials for the IAM user."
}
