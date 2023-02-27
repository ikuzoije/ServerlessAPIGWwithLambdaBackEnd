variable "aws_region" {
  description = "Region where resource is being Provisioned"
  type        = string
  default     = "us-east-1"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS_ACCESS_KEY_ID"
  type        = string
  default     = "Put your access key ID here"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS_SECRET_ACCESS_KEY"
  type        = string
  default     = "Put your secret access key here"
}

variable "s3_bucket_name" {
  description = "s3 bucket to store lambda function"
  default     = "ik-lambda-proj-bucket"
}
