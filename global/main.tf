provider "aws" {
  region = "us-east-1"
}

module "random_number_alpha" {
  source = "git::https://github.com/shellwhale/test-module.git//modules/random_number"
  name               = "random_number_alpha"
}
