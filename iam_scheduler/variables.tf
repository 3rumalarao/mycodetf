variable "role_name_prefix" {
  description = "Prefix for the IAM role name (e.g., 'myorg-dev')."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic the Lambda needs permission to publish to."
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function for scoping log permissions."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role."
  type        = map(string)
  default     = {}
}

# Required for constructing ARNs accurately
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
