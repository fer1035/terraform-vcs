/* AWS provider. Set deploy region and default tags that will be
propagated to all taggable resources. */
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

/* Network module. Provision a VPC and all of its components including
Subnets, Internet Gateways, NAT gateways, Routing Tables, etc. Security
Groups are provisioned separately as standard use-cases require multiple
Security Groups for an application. */
module "network" {
  source                = "app.terraform.io/fer1035/network/aws"
  vpc_cidr              = "10.0.0.0/16"
  subnet_public_1_cidr  = "10.0.0.0/24"
  subnet_private_1_cidr = "10.0.1.0/24"
  subnet_private_2_cidr = "10.0.2.0/24"
}

/* Security Group module. Provision Security Groups by specifying ports,
protocols, and other configuration details for each group. This module
uses outputs from the Network module as its inputs. */
module "security-group" {
  source           = "app.terraform.io/fer1035/security-group/aws"
  ingress_from     = 22
  ingress_to       = 22
  ingress_cidr     = "0.0.0.0/0"
  ingress_protocol = "tcp"
  sg_description   = "Test SG."
  vpc_id           = module.network.vpc_id
}

/* EC2 Instance module. Provision an EC2 virtual machine Instance into a
Subnet and attach Security Groups. This module uses outputs from the Network
and Security Group modules as its inputs. */
module "ec2-instance-1" {
  source          = "app.terraform.io/fer1035/ec2-instance/aws"
  subnet          = module.network.public_subnet_1
  security_groups = [module.security-group.security_group_id]
  instance_type   = "t3a.medium"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN5A0ppqf2Dj6b7w9VgBiIR3/KwUONb2oUI55IFjU5S1An2j7jPgaoxGjZDhLuU5OEmXnuG7llJGor+3/uwV2lhZ/WtNpI2PopbjZVAWv4nPX4SRWPZ1uYabtydbeUHyHD+FXRfRA+hHsFlYyUdyif9QyNj7U/lM3I9E9igf6j2aUfbJiizTsGpabOxd14Hw7fXRNP8gF1nhw6ek4w3js4nWgY6nmSnQVeelOIU1zNzi35bRL0mJTpEQBJMJP1+0nd1Xl9g7J8f9w6cFCZNk5X16SDlyApusiLSkO5HmmLaKF+jDbMhs8bVOkLHvt3ScmNs2hvGwXCTr40qwDpky7ATvoShNHZJPImUSOz9arcfP5wrar4MHhonM5L3vmmcS6yB4bM0yIpcTM+IInsHf5nvs2i71BKj+opMtTEin/lUxdZauu/G4a/Kctz8pQAZScAV4KmzF9e/XqdvXZJahoFFalf6yXSg2bPYbgjfuIiuOwSMkKgN1iNIoa0DLnqTFs= abdahmad@Ahmads-MacBook-Pro.local"
}

/* EC2 Instance module. Provision an EC2 virtual machine Instance into a
Subnet and attach Security Groups. This module uses outputs from the Network
and Security Group modules as its inputs. */
module "ec2-instance-2" {
  source          = "app.terraform.io/fer1035/ec2-instance/aws"
  subnet          = module.network.public_subnet_1
  security_groups = [module.security-group.security_group_id]
  instance_type   = "t3a.medium"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN5A0ppqf2Dj6b7w9VgBiIR3/KwUONb2oUI55IFjU5S1An2j7jPgaoxGjZDhLuU5OEmXnuG7llJGor+3/uwV2lhZ/WtNpI2PopbjZVAWv4nPX4SRWPZ1uYabtydbeUHyHD+FXRfRA+hHsFlYyUdyif9QyNj7U/lM3I9E9igf6j2aUfbJiizTsGpabOxd14Hw7fXRNP8gF1nhw6ek4w3js4nWgY6nmSnQVeelOIU1zNzi35bRL0mJTpEQBJMJP1+0nd1Xl9g7J8f9w6cFCZNk5X16SDlyApusiLSkO5HmmLaKF+jDbMhs8bVOkLHvt3ScmNs2hvGwXCTr40qwDpky7ATvoShNHZJPImUSOz9arcfP5wrar4MHhonM5L3vmmcS6yB4bM0yIpcTM+IInsHf5nvs2i71BKj+opMtTEin/lUxdZauu/G4a/Kctz8pQAZScAV4KmzF9e/XqdvXZJahoFFalf6yXSg2bPYbgjfuIiuOwSMkKgN1iNIoa0DLnqTFs= abdahmad@Ahmads-MacBook-Pro.local"
}

/* Data block. Call the provisioned resource as a data source and read details
about the resource. */
data "aws_instance" "instance_1" {
  instance_id = split("/", module.ec2-instance-1.instance_arn)[1]
}

/* Data block. Call the provisioned resource as a data source and read details
about the resource. */
data "aws_instance" "instance_2" {
  instance_id = split("/", module.ec2-instance-2.instance_arn)[1]
}

/* Output blocks. Display output values from modules, resources,
and data blocks. */
output "instance_1_private_dns_data" {
  value       = data.aws_instance.instance_1.private_dns
  description = "Private DNS address for the EC2 instance."
}
output "instance_1_private_ip_data" {
  value       = data.aws_instance.instance_1.private_ip
  description = "Private IP address for the EC2 instance."
}
output "instance_1_public_dns_data" {
  value       = data.aws_instance.instance_1.public_dns
  description = "Public DNS address for the EC2 instance."
}
output "instance_1_public_ip_data" {
  value       = data.aws_instance.instance_1.public_ip
  description = "Public IP address for the EC2 instance."
}
output "instance_1_arn" {
  value       = module.ec2-instance-1.instance_arn
  description = "ARN of the EC2 instance."
}

/* Output blocks. Display output values from modules, resources,
and data blocks. */
output "instance_2_private_dns_data" {
  value       = data.aws_instance.instance_2.private_dns
  description = "Private DNS address for the EC2 instance."
}
output "instance_2_private_ip_data" {
  value       = data.aws_instance.instance_2.private_ip
  description = "Private IP address for the EC2 instance."
}
output "instance_2_public_dns_data" {
  value       = data.aws_instance.instance_2.public_dns
  description = "Public DNS address for the EC2 instance."
}
output "instance_2_public_ip_data" {
  value       = data.aws_instance.instance_2.public_ip
  description = "Public IP address for the EC2 instance."
}
output "instance_2_arn" {
  value       = module.ec2-instance-2.instance_arn
  description = "ARN of the EC2 instance."
}
