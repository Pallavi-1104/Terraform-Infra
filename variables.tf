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

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
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
