## Prerequisites

- Terraform `>= 1.5.0`
- AWS CLI configured with credentials for the target account
- Sufficient IAM permissions: `ec2:*`, `iam:*`, `logs:*`, `s3:*`, `dynamodb:*`

---

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


