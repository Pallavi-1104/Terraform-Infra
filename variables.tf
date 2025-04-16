variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS CLI profile name to use"
  type        = string
  default     = "default"
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "nodejs_image" {
  description = "Docker image for Node.js app"
  type        = string
  default     = "node:18"
}

variable "mongodb_image" {
  description = "Docker image for MongoDB"
  type        = string
  default     = "mongo:5"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Max size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Min size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "Key pair name for EC2 SSH access"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}