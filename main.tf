/* This Terraform configuration serves to demonstrate using multiple predefined
modules from private registries to deploy a complete application without changing
module codes, only specifying inputs and outputs in the process.

Updated: Tue May 10 13:40:39 +08 2022 */

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

/* data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

module "rest-api" {
  source          = "app.terraform.io/fer1035/rest-api/aws"
  api_description = "API test for Terraform module development."
  api_name        = "terraform_api"
  stage_name      = "dev"
  use_waf         = false
}

module "rest-api-lambda-endpoint" {
  source            = "app.terraform.io/fer1035/rest-api-lambda-endpoint/aws"
  api_description   = module.rest-api.api_description
  api_name          = module.rest-api.api_name
  api_execution_arn = module.rest-api.api_execution_arn
  parent_id         = module.rest-api.api_root_id
  api_id            = module.rest-api.api_id
  api_validator     = module.rest-api.api_validator
  path_part         = "event"
  http_method       = "POST"
  cors              = module.rest-api.cors
  api_endpoint_model = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "UserModel",
  "type": "object",
  "required": [
    "myname"
  ],
  "properties": {
    "myname": {"type": "string"}
  },
  "additionalProperties": false
}
EOF
  lambda_env_variables = {
    ENCODiNG: "latin-1",
    CORS: module.rest-api.cors
  }
}

# Outputs.
output "api_key" {
  value       = nonsensitive(module.rest-api.api_key)
  description = "API key."
}
output "api_endpoint_url" {
  value       = "${module.rest-api.api_url}${module.rest-api-lambda-endpoint.api_endpoint}"
  description = "API endpoint URL."
}
output "api_deploy_cli" {
  value       = "aws apigateway create-deployment --rest-api-id ${module.rest-api.api_id} --stage-name ${module.rest-api.stage_name} --description 'Redeploying stage for Terraform changes.'[ --profile <your_CLI_profile>]"
  description = "AWSCLI command to redeploy the API and activate changes."
} */

module "network" {
  source                = "app.terraform.io/fer1035/network/aws"
  vpc_cidr              = "10.0.0.0/16"
  subnet_public_1_cidr  = "10.0.0.0/24"
  subnet_private_1_cidr = "10.0.1.0/24"
  subnet_private_2_cidr = "10.0.2.0/24"
}

module "security-group" {
  source           = "app.terraform.io/fer1035/security-group/aws"
  ingress_from     = 22
  ingress_to       = 22
  ingress_cidr     = "0.0.0.0/0"
  ingress_protocol = "tcp"
  sg_description   = "Test SG."
  vpc_id           = module.network.vpc_id
}

module "ec2-instance" {
  source          = "app.terraform.io/fer1035/ec2-instance/aws"
  subnet          = module.network.public_subnet_1
  security_groups = [module.security-group.security_group_id]
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN5A0ppqf2Dj6b7w9VgBiIR3/KwUONb2oUI55IFjU5S1An2j7jPgaoxGjZDhLuU5OEmXnuG7llJGor+3/uwV2lhZ/WtNpI2PopbjZVAWv4nPX4SRWPZ1uYabtydbeUHyHD+FXRfRA+hHsFlYyUdyif9QyNj7U/lM3I9E9igf6j2aUfbJiizTsGpabOxd14Hw7fXRNP8gF1nhw6ek4w3js4nWgY6nmSnQVeelOIU1zNzi35bRL0mJTpEQBJMJP1+0nd1Xl9g7J8f9w6cFCZNk5X16SDlyApusiLSkO5HmmLaKF+jDbMhs8bVOkLHvt3ScmNs2hvGwXCTr40qwDpky7ATvoShNHZJPImUSOz9arcfP5wrar4MHhonM5L3vmmcS6yB4bM0yIpcTM+IInsHf5nvs2i71BKj+opMtTEin/lUxdZauu/G4a/Kctz8pQAZScAV4KmzF9e/XqdvXZJahoFFalf6yXSg2bPYbgjfuIiuOwSMkKgN1iNIoa0DLnqTFs= abdahmad@Ahmads-MacBook-Pro.local"
}

output "instance_private_dns" {
  value       = module.ec2-instance.private_dns
  description = "Private DNS address for the EC2 instance."
}
