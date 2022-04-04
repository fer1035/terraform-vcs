# This Terraform configuration serves to demonstrate using multiple predefined modules from private registries to deploy a complete application without changing module codes, only specifying inputs and outputs in the process.

# Account & deployment data.
data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Working region."
}
provider "aws" {
  region = var.region
}

# Required tags data.
variable "tag_Name" {
  type        = string
  default     = "VCS Test"
  description = "Human-friendly name for the project resources."
}
variable "tag_sitecode" {
  type        = string
  default     = "123"
  description = "Which site the project is attached to."
}
variable "tag_department" {
  type        = string
  default     = "Demolition"
  description = "Which department owns the project."
}
variable "tag_team" {
  type        = string
  default     = "myteam@mycompany.com"
  description = "Which team owns the project."
}
variable "tag_tier" {
  type        = string
  default     = "dev"
  description = "Deployment tier for the resources."
}
variable "tag_costcenter" {
  type        = string
  default     = "1234"
  description = "Which cost center the project is attached to."
}

# Modules.
module "static-website" {
  source         = "app.terraform.io/fer1035/static-website/aws"
  region         = var.region
  tag_Name       = var.tag_Name
  tag_sitecode   = var.tag_sitecode
  tag_department = var.tag_department
  tag_team       = var.tag_team
  tag_tier       = var.tag_tier
  tag_costcenter = var.tag_costcenter
}
module "cloudfront-invalidator" {
  source         = "app.terraform.io/fer1035/s3-cloudfront-invalidator/aws"
  region         = var.region
  tag_Name       = var.tag_Name
  tag_sitecode   = var.tag_sitecode
  tag_department = var.tag_department
  tag_team       = var.tag_team
  tag_tier       = var.tag_tier
  tag_costcenter = var.tag_costcenter
  bucket_name    = module.static-website.s3_bucket_name
  bucket_arn     = module.static-website.s3_bucket_arn
  cloudfront_id  = module.static-website.cloudfront_id
  cloudfront_arn = module.static-website.cloudfront_arn
}
module "network" {
  source                = "app.terraform.io/fer1035/network/aws"
  region                = var.region
  tag_Name              = var.tag_Name
  tag_sitecode          = var.tag_sitecode
  tag_department        = var.tag_department
  tag_team              = var.tag_team
  tag_tier              = var.tag_tier
  tag_costcenter        = var.tag_costcenter
  vpc_cidr              = "10.0.0.0/16"
  subnet_public_1_cidr  = "10.0.0.0/24"
  subnet_private_1_cidr = "10.0.1.0/24"
  subnet_private_2_cidr = "10.0.2.0/24"
}
module "security-group" {
  source           = "app.terraform.io/fer1035/security-group/aws"
  region           = var.region
  tag_Name         = var.tag_Name
  tag_sitecode     = var.tag_sitecode
  tag_department   = var.tag_department
  tag_team         = var.tag_team
  tag_tier         = var.tag_tier
  tag_costcenter   = var.tag_costcenter
  ingress_from     = 80
  ingress_to       = 80
  ingress_protocol = "tcp"
  sg_description   = "Test Security Group for Terraform."
  vpc_id           = module.network.vpc_id
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
output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID."
}
output "security_group_id" {
  value       = module.security-group.security_group_id
}
