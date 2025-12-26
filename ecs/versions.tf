terraform {
 required_version = ">= 1.12.2"
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 6.20"
   }
   random = {
     source  = "hashicorp/random"
     version = "~> 3.0"
   }
   cloudinit = {
     source  = "hashicorp/cloudinit"
     version = "~> 2.1"
   }
 }
}
