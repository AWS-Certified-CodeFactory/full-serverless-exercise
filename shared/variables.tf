locals {
  common_tags = {
    org     = var.org
    env     = var.env
    project = "full-serverless"
  }
}

variable "org" {
  description = "Name of the Organization"
  type        = string
  default     = "fs-aws"
}

variable "env" {
  description = "Name of the Environment"
  type        = string
  default     = "shared"
}

variable "aws_region" {
  description = "AWS Resources created region"
  type        = string
  default     = "us-east-1"
}