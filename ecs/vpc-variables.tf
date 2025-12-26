#	Enviornment Variable

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "testing"
}

# Buisness Division

variable "owners" {
  description = "Organization this Infrastructure belongs"
  type        = string
  default     = "aalevoor"
}

# 	VPC variable defined

variable "name" {
  description = "VPC Name"
  type        = string
  default     = "ec2-vpc"
}

#	VPC CIDR Block

variable "cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

# 	VPC AZS

variable "azs" {
  description = "A list of Availability zones in the region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

#	VPC Public Subnets

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

#	VPC Private Subnets

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# VPC Enable NAT Gateway (True or False)

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

# VPC Single NAT Gateway (True or False)

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}
