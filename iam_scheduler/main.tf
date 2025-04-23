# IAM Role for Lambda Execution
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_scheduler" {
  name               = "${var.role_name_prefix}-scheduler-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

# IAM Policy Document defining Lambda Permissions
data "aws_iam_policy_document" "lambda_scheduler_permissions" {
  # EC2 Permissions
  statement {
    sid    = "EC2Actions"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances", # Needed for filtering by tag
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = ["*"] # DescribeInstances requires '*' for tag filtering
  }

  # RDS Permissions
  statement {
    sid    = "RDSActions"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances", # Needed for filtering by tag (via ListTagsForResource)
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:ListTagsForResource"  # Essential for reliable RDS tag filtering
    ]
    # DescribeDBInstances and ListTagsForResource generally need '*'
    # Start/Stop can be scoped if ARNs are known/predictable, but '*' is often practical here.
    resources = ["*"]
  }

  # SNS Publish Permissions
  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [var.sns_topic_arn] # Best Practice: Scope to the specific topic
  }

  # CloudWatch Logs Permissions
  statement {
    sid    = "LambdaLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",    # Allows Lambda to create its log group if needed
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    # Best Practice: Scope logs permissions to the specific Lambda function's potential log group
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"]
  }
}

# Attach the Policy to the Role
resource "aws_iam_role_policy" "lambda_scheduler_policy" {
  name   = "${var.role_name_prefix}-scheduler-lambda-policy"
  role   = aws_iam_role.lambda_scheduler.id
  policy = data.aws_iam_policy_document.lambda_scheduler_permissions.json
}
