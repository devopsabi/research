locals {
  owners      = var.owners
  environment = var.environment
  name        = "${local.owners}-${local.environment}"
  project     = "eks-abhishek"
  tags = {
    owners      = local.owners
    environment = local.environment
  }
}
