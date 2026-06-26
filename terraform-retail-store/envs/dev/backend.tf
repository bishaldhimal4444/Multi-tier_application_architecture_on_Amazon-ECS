terraform {
  backend "s3" {
    bucket         = "bsl-dml-retail-store-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "retail-store-terraform-lock"
    encrypt        = true
  }
}