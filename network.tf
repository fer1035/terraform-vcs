module "network" {
  source                = "app.terraform.io/fer1035/network/aws"
  # insert required variables here
  vpc_cidr              = "10.0.0.0/16"
  subnet_public_1_cidr  = "10.0.0.0/24"
  subnet_private_1_cidr = "10.0.1.0/24"
  subnet_private_2_cidr = "10.0.2.0/24"
}

output "vpc_id" {
  value = module.network.vpc_id
  description = "The VPC ID."
}
