/* This Terraform configuration serves to demonstrate using multiple predefined
modules from private registries to deploy a complete application without changing
module codes, only specifying inputs and outputs in the process.

Updated: Fri Apr  8 11:54:54 +08 2022 */

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
