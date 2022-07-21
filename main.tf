# AWS provider. Set deploy region and default tags that will be
# propagated to all taggable resources.
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

module "static_website" {
  source  = "app.terraform.io/fer1035/static-website/aws"
  version = "1.1.4"
}

output "bucket_name" {
  value       = module.static_website.bucket_name
  description = "Web host bucket name."
}
output "cloudfront_domain" {
  value       = module.static_website.cloudfront_domain
  description = "Website domain."
}
