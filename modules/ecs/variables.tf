variable "ecs_cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ECS service"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ECS tasks and load balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources are deployed"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Key pair name for EC2 access"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task"
}

variable "nodejs_image" {
  description = "Docker image for Node.js app"
  type        = string
}

variable "mongodb_image" {
  description = "Docker image for MongoDB"
  type        = string
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "region" {
  type = string
}
