terraform {
  backend "s3" {
    bucket         = "project-name-terraform-state-s3bucket-162504351442"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project_name-terraform-state-lock-DynamoDBTable"
    encrypt        = true
  }
}
