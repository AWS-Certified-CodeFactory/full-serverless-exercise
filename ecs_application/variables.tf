variable "org" {
  description = "Name of the Organization"
  type        = string
  default     = "fs-aws"
}

variable "env" {
  description = "Name of the Environment"
  type        = string
  default     = "dev"
}

variable "cluster_id" {}
variable "vpc_id" {}
variable "subnets" {}
variable "security_group_id" {}
variable "service_registry_arn" {}
variable "common_tags" {}
variable "target_group_name" {
  default = ""
}

variable "app_name" {}

variable "image" {
  default = "nginx"
}

variable "cpu" {
  default = 100
}

variable "cpu_container" {
  default = "256"
}

variable "memory" {
  default = 512
}

variable "memory_container" {
  default = "512"
}

variable "desired_count" {
  default = 1
}

variable "environment_variables" {
  default = [
    {
      name  = "FOO"
      value = "BAR"
    }
  ]
}

variable "secrets" {
  default = []
}

variable "task_execution_role_arn" {}
variable "task_role_arn" {}