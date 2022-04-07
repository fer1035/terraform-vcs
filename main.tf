/* This Terraform configuration serves to demonstrate using multiple predefined
modules from private registries to deploy a complete application without changing
module codes, only specifying inputs and outputs in the process.

Updated: Thu Apr  7 22:28:37 +08 2022 */

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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

module "appstream" {
  source           = "app.terraform.io/fer1035/appstream/aws"
  app_description  = "Terraform AppStream module test."
  app_name         = "terraform-appstream"
  feedback_url     = null
  redirect_url     = null
  image_name       = "Amazon-AppStream2-Sample-Image-02-04-2019"
  compute_capacity = 1
}

module "rest-api" {
  source          = "app.terraform.io/fer1035/rest-api/aws"
  api_description = "API test for Terraform module development."
  api_name        = "appstream_api"
  stage_name      = "dev"
}

module "rest-api-lambda-endpoint" {
  source            = "app.terraform.io/fer1035/rest-api-lambda-endpoint/aws"
  api_description   = module.rest-api.api_description
  api_name          = module.rest-api.api_name
  api_execution_arn = module.rest-api.api_execution_arn
  path_part         = "register"
  parent_id         = module.rest-api.api_root_id
  api_id            = module.rest-api.api_id
  api_validator     = module.rest-api.api_validator
  cors              = module.rest-api.cors
  http_method       = "POST"
  lambda_key        = "appstream_api_function.zip"
  lambda_key_sha256 = "appstream_api_function.zip.sha256.txt"
  lambda_env_variables = {
    ENCODiNG: "latin-1",
    CORS: "*",
    IP_TABLE: "${module.appstream.ip_table}",
    EMAIL_TABLE: "${module.appstream.email_table}",
    STACK: "${module.appstream.stack_name}",
    FLEET: "${module.appstream.fleet_name}",
    APP: "${module.appstream.image_name}",
    AUTH_TYPE: "${module.appstream.auth_type}",
    GAP_TIME: 1,
    SIM_VALIDITY: 3600
  }
  lambda_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonAppStreamFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
  api_endpoint_model = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "UserModel",
  "type": "object",
  "properties": {
    "email": {"type": "string"},
    "first_name": {"type": "string"},
    "last_name": {"type": "string"}
  }
}
EOF
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
}
