locals {
  name_prefix_iam     = format("%s%s", local.project, title(local.cluster_name))
  cluster_policy_name = format("%sEKSPolicy", local.name_prefix_iam)
}

data "aws_iam_policy_document" "custom" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = [
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AutomationAssumedForSSMRunbook"
    effect  = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:ListAttachedRolePolicies",
      "eks:DescribeCluster",
      "ssm:DescribeInstanceInformation",
      "ssm:ListCommandInvocations",
      "ssm:ListCommands",
      "ssm:SendCommand"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "custom" {
  name   = local.cluster_policy_name
  policy = data.aws_iam_policy_document.custom.json
  tags   = merge(local.tags, {
    Name = local.cluster_policy_name
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = module.eks.cluster_role_name
  policy_arn = aws_iam_policy.custom.arn
  depends_on = [
    module.eks
  ]
}
