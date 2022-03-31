provider "aws" {
  region = "us-east-1"
}

module "static-website" {
  source         = "app.terraform.io/fer1035/static-website/aws"
  version        = "1.0.6"
  # insert required variables here
  tag_Name       = "VCS Test"
  tag_sitecode   = "123"
  tag_department = "Demolition"
  tag_team       = "myteam@mycompany.com"
  tag_tier       = "dev"
  tag_costcenter = "1234"
}

output "website_url" {
  value       = module.static-website.cloudfront_domain
  description = "The CloudFront Distribution domain."
}
