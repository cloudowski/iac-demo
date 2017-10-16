provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-state-iac-demo"
  acl    = "private"
}

resource "aws_dynamodb_table" "tfstate" {
  name           = "terraform-state-iac-demo"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
