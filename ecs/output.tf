# 	Outputs

#	VPC ID

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc.vpc_id
}

#	VPC CIDR blocks

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.networking.vpc.vpc_cidr_block
}

# VPC Private Subnets

output "private_subnets" {
  description = "A list of private_subnets inside the VPC"
  value       = module.networking.vpc.private_subnets
}

# VPC Public Subnets

output "public_subnets" {
  description = "A list of public_subnets inside the VPC"
  value       = module.networking.vpc.public_subnets
}

# VPC NAT Gateway Public IP

output "nat_public_ips" {
  description = "List of pub;ic Elastic IPs created for AWS NAT Gateway"
  value       = module.networking.vpc.nat_public_ips
}

# VPC AZS

output "azs" {
  description = "A list of Availability zones specified as argument to this module"
  value       = module.networking.vpc.azs
}



output "alb" {
  description = "ALB"
  value = aws_lb.this.dns_name
}
