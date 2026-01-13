variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "k8s-abhishek"
}

variable "cluster_version" {
  description = "Cluster Version"
  type        = string
  default     = "1.32"
}

variable "aws_account_id" {
  description = "AWS ACCOUNT id"
  type        = string
  default     = "xxxxxxxxxxx"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.small"
}

variable "iam_access_entries" {
type = list(object({
    policy_arn     = string
    principal_arn  = string
  }))

  default = [
    {
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      principal_arn = "arn:aws:iam::xxxxxxxxxxx:role/aa-ViewOnly-AWSServiceRoleForAmazonEKS"
    }
  ]
}
