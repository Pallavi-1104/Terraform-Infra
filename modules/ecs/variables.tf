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

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS Auto Scaling Group"
  type        = list(string)
}

variable "asg_desired_capacity" {
  description = "Desired number of ECS instances"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of ECS instances"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of ECS instances"
  type        = number
}

variable "target_group_arns" {
  description = "Target group ARNs for attaching instances"
  type        = list(string)
  default     = []
}
