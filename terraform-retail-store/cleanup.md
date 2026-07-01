Create a cleanup.sh file

```
touch cleanup.sh
```

and Paste the below scripts in the cleanup.sh file:

```
#!/bin/bash
set -e

AWS_REGION="us-east-1"

echo "=============================="
echo "Deleting ECS Infrastructure..."
echo "=============================="

##############################################
# 1. Delete ECS Service
##############################################
echo "Deleting ECS service..."

aws ecs update-service \
    --cluster retail-store-ecs-cluster \
    --service ui \
    --desired-count 0 \
    --region $AWS_REGION || true

echo "Waiting 30 seconds..."
sleep 30

aws ecs delete-service \
    --cluster retail-store-ecs-cluster \
    --service ui \
    --force \
    --region $AWS_REGION || true

##############################################
# 2. Delete Task Definitions
##############################################
echo "Deleting task definitions..."

TASKS=$(aws ecs list-task-definitions \
    --family-prefix retail-store-ecs-ui \
    --query 'taskDefinitionArns[]' \
    --output text \
    --region $AWS_REGION)

for task in $TASKS
do
    echo "Deregistering $task"
    aws ecs deregister-task-definition \
        --task-definition "$task" \
        --region $AWS_REGION
done

##############################################
# 3. Delete ECS Cluster
##############################################
echo "Deleting ECS cluster..."

aws ecs delete-cluster \
    --cluster retail-store-ecs-cluster \
    --region $AWS_REGION || true

##############################################
# 4. Delete CloudWatch Log Group
##############################################
echo "Deleting Log Group..."

aws logs delete-log-group \
    --log-group-name retail-store-ecs-tasks \
    --region $AWS_REGION || true

##############################################
# 5. Delete Target Group
##############################################
echo "Deleting Target Group..."

TG_ARN=$(aws elbv2 describe-target-groups \
    --names retail-store-ui-tg \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

if [[ "$TG_ARN" != "None" && -n "$TG_ARN" ]]; then
    aws elbv2 delete-target-group \
        --target-group-arn "$TG_ARN" \
        --region $AWS_REGION
fi

##############################################
# 6. Delete Listener
##############################################
echo "Deleting Listener..."

LB_ARN=$(aws elbv2 describe-load-balancers \
    --names retail-store-alb \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

if [[ "$LB_ARN" != "None" && -n "$LB_ARN" ]]; then

LISTENERS=$(aws elbv2 describe-listeners \
    --load-balancer-arn "$LB_ARN" \
    --query 'Listeners[].ListenerArn' \
    --output text \
    --region $AWS_REGION)

for listener in $LISTENERS
do
    aws elbv2 delete-listener \
        --listener-arn "$listener" \
        --region $AWS_REGION
done

fi

##############################################
# 7. Delete Load Balancer
##############################################
echo "Deleting ALB..."

if [[ "$LB_ARN" != "None" && -n "$LB_ARN" ]]; then

aws elbv2 delete-load-balancer \
    --load-balancer-arn "$LB_ARN" \
    --region $AWS_REGION

echo "Waiting for ALB deletion..."
sleep 60

fi

##############################################
# 8. Delete Security Groups
##############################################
echo "Deleting Security Groups..."

aws ec2 delete-security-group \
    --group-name retail-store-ui-sg \
    --region $AWS_REGION || true

aws ec2 delete-security-group \
    --group-name retail-store-alb-sg \
    --region $AWS_REGION || true

##############################################
# 9. Delete NAT Gateway
##############################################
echo "Deleting NAT Gateway..."

NAT_ID=$(aws ec2 describe-nat-gateways \
    --filter Name=state,Values=available \
    --query 'NatGateways[0].NatGatewayId' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

if [[ "$NAT_ID" != "None" && -n "$NAT_ID" ]]; then

aws ec2 delete-nat-gateway \
    --nat-gateway-id "$NAT_ID" \
    --region $AWS_REGION

echo "Waiting 90 seconds..."
sleep 90

fi

##############################################
# 10. Release Elastic IP
##############################################
echo "Releasing Elastic IP..."

ALLOC=$(aws ec2 describe-addresses \
    --query 'Addresses[0].AllocationId' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

if [[ "$ALLOC" != "None" && -n "$ALLOC" ]]; then

aws ec2 release-address \
    --allocation-id "$ALLOC" \
    --region $AWS_REGION

fi

##############################################
# 11. Delete Route Tables
##############################################
echo "Deleting Route Tables..."

for rt in $(aws ec2 describe-route-tables \
    --filters Name=tag:Name,Values='retail-store-*' \
    --query 'RouteTables[].RouteTableId' \
    --output text \
    --region $AWS_REGION)
do
    aws ec2 delete-route-table \
        --route-table-id "$rt" \
        --region $AWS_REGION || true
done

##############################################
# 12. Delete Subnets
##############################################
echo "Deleting Subnets..."

for subnet in $(aws ec2 describe-subnets \
    --filters Name=tag:Project,Values=RetailStore \
    --query 'Subnets[].SubnetId' \
    --output text \
    --region $AWS_REGION)
do
    aws ec2 delete-subnet \
        --subnet-id "$subnet" \
        --region $AWS_REGION || true
done

##############################################
# 13. Detach & Delete Internet Gateway
##############################################
echo "Deleting Internet Gateway..."

IGW=$(aws ec2 describe-internet-gateways \
    --filters Name=tag:Project,Values=RetailStore \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

VPC=$(aws ec2 describe-vpcs \
    --filters Name=tag:Project,Values=RetailStore \
    --query 'Vpcs[0].VpcId' \
    --output text \
    --region $AWS_REGION 2>/dev/null || true)

if [[ "$IGW" != "None" && "$VPC" != "None" && -n "$IGW" && -n "$VPC" ]]; then

aws ec2 detach-internet-gateway \
    --internet-gateway-id "$IGW" \
    --vpc-id "$VPC" \
    --region $AWS_REGION || true

aws ec2 delete-internet-gateway \
    --internet-gateway-id "$IGW" \
    --region $AWS_REGION

fi

##############################################
# 14. Delete VPC
##############################################
echo "Deleting VPC..."

if [[ "$VPC" != "None" && -n "$VPC" ]]; then

aws ec2 delete-vpc \
    --vpc-id "$VPC" \
    --region $AWS_REGION

fi

##############################################
# 15. Delete IAM Roles
##############################################
echo "Deleting IAM Roles..."

aws iam detach-role-policy \
    --role-name retailStoreEcsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy || true

aws iam delete-role \
    --role-name retailStoreEcsTaskExecutionRole || true

aws iam delete-role \
    --role-name retailStoreEcsTaskRole || true

echo ""
echo "========================================="
echo "Infrastructure cleanup completed."
echo "========================================="
```

Provide execute permission for running script:

```
chmod +x cleanup.sh
```

Run the script:

```
./cleanup.sh
```
