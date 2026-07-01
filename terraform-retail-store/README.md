## Prerequisites

Before deploying, ensure we have:

- AWS CLI configured
- Terraform installed (v1.5+ recommended)
- An AWS account with sufficient IAM permissions: `ec2:*`, `iam:*`, `logs:*`, `s3:*`, `dynamodb:*`
- An S3 bucket for storing the Terraform remote state

Verify your AWS credentials:

```bash
aws sts get-caller-identity
```

## 1. Bootstrap — Remote State Backend

Run once per account before the first `terraform init`.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="bsl-dml-retail-store-terraform-state"
```

**Create S3 bucket:**

```bash
aws s3 mb s3://$BUCKET_NAME --region us-east-1
```

**Enable versioning** (required — state locking depends on it):

```bash
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

**Enable encryption:**

```bash
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

**Block public access** (belt-and-suspenders):

```bash
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

**Create DynamoDB table for state locking:**

```bash
aws dynamodb create-table \
  --table-name retail-store-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

echo "Backend ready. Bucket: $BUCKET_NAME"
```

# Terraform Deployment Guide

This directory contains the Terraform configuration used to provision the infrastructure for the **Retail Store Multi-tier Application** on Amazon ECS Fargate.

## Project Structure

```
terraform-retail-store/
├── modules/
│   ├── alb/
│   ├── cloudwatch/
│   ├── ecs/
│   ├── iam/
│   ├── security-groups/
│   └── vpc/
│
└── envs/
    └── dev/
        ├── backend.tf
        ├── provider.tf
        ├── versions.tf
        ├── variables.tf
        ├── terraform.tfvars
        ├── main.tf
        ├── outputs.tf
        └── locals.tf
```

## Configure Variables

Create a `terraform.tfvars` file inside:

```
envs/dev/
```

Example:

```
project_name = "retail-store"
environment  = "dev"
aws_region   = "us-east-1"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

container_image = "public.ecr.aws/aws-containers/retail-store-sample-ui:1.2.3"
ui_theme        = "blue"
```

## Initialize Terraform

```
terraform init
```

## Validate Configuration

```
terraform validate
```

## Review Execution Plan

```
terraform plan
```

## Deploy Infrastructure

```
terraform apply
```

Type:

```
yes
```

when prompted.

## Verify Deployment

After deployment completes:

```
terraform output
```

Open the Application Load Balancer DNS name in your browser to access the application.

## Update the Application

To deploy a new application version or change the UI theme:

1. Update the required values in `terraform.tfvars`.

Example:

```
container_image = "public.ecr.aws/aws-containers/retail-store-sample-ui:1.2.4"

ui_theme = "green"
```

2. Apply the changes:

```
terraform fmt -recursive
terraform plan
terraform apply
```

Terraform creates a new ECS Task Definition revision and performs a rolling deployment automatically.

## Destroy Infrastructure

To remove all deployed AWS resources:

```
terraform destroy
```

Type:

```
yes
```

when prompted.

## Notes

- Infrastructure is fully managed using Terraform.
- ECS Task Definitions are immutable; each configuration change creates a new revision.
- ECS Services perform rolling deployments automatically.
- Terraform state is stored remotely in an S3 backend.

```
terraform init
terraform fmt -recursive
terraform validate

terraform plan -out=tfplan
terraform show tfplan

terraform apply tfplan

terraform output = quick way to retrieve useful information from your deployed infrastructure.
terraform state list = shows all infrastructure Terraform is currently tracking.
terraform state show module.ec2.aws_instance.web

terraform plan -destroy -out=tfdestroy
terraform apply tfdestroy
```
