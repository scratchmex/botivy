## Variables
variable "function_name" {
  type = string
  default = "ivy-bot-terraform"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "image_tag" {
  type = string
  default = "latest"
}

variable "GITHUB_TOKEN" {
  type = string
  sensitive = true
}

variable "GITHUB_REPO" {
  type = string
}

## Data
data "aws_caller_identity" "this" {}
data "aws_region" "current" {
    name = var.region
}
data "aws_ecr_authorization_token" "token" {}

## Locals
locals {
  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, var.region)
  ecr_image = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.this.id, var.image_tag)
}
