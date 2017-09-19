provider "aws" {
  region = "eu-west-1"
}

//  Create the OpenShift cluster using our module.
module "vpc" {
  source = "git::https://github.com/cloudowski/terraform-vpc.git"
  cidr   = "10.0.0.0/16"
}
