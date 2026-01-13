# 	Outputs

#	VPC ID

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

#	VPC CIDR blocks

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Private Subnets

output "private_subnets" {
  description = "A list of private_subnets inside the VPC"
  value       = module.vpc.private_subnets
}

# VPC Public Subnets

output "public_subnets" {
  description = "A list of public_subnets inside the VPC"
  value       = module.vpc.public_subnets
}

# VPC NAT Gateway Public IP

output "nat_public_ips" {
  description = "List of pub;ic Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC AZS

output "azs" {
  description = "A list of Availability zones specified as argument to this module"
  value       = module.vpc.azs
}

# EKS

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

#output "cluster_oidc_issuer_url" {
#  description = "Kubernetes Cluster Name"
#  value       = module.eks.cluster_oidc_issuer_url
#}
