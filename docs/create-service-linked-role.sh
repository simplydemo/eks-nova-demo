# for ELB (AWSServiceRoleForElasticLoadBalancing)
aws iam create-service-linked-role --aws-service-name 'elasticloadbalancing.amazonaws.com'

# for ASG (AWSServiceRoleForAutoScaling)
aws iam create-service-linked-role --aws-service-name 'autoscaling.amazonaws.com'

# for EKS (AWSServiceRoleForAmazonEKS)
aws iam create-service-linked-role --aws-service-name 'eks.amazonaws.com'

# for ECS (AWSServiceRoleForECS)
aws iam create-service-linked-role --aws-service-name 'ecs.amazonaws.com'

# for EKS Fargate (AWSServiceRoleForAmazonEKSForFargate)
aws iam create-service-linked-role --aws-service-name 'eks-fargate.amazonaws.com'

# for EKS NodeGroup (AWSServiceRoleForAmazonEKSNodegroup)
aws iam create-service-linked-role --aws-service-name 'eks-nodegroup.amazonaws.com'

# for RDS (AWSServiceRoleForRDS)
aws iam create-service-linked-role --aws-service-name 'rds.amazonaws.com'

