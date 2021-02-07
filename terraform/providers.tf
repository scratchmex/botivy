provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_get_ec2_platforms = true
  skip_metadata_api_check = true
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}