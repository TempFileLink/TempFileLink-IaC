variable "credentials" {
  description = "AWS credentials"
  type = object({
    access_key = string
    secret_key = string
  })
  sensitive = true
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "my-vpc"
    cidr = "10.0.0.0/16"
  }
}

variable "ec2" {
  description = "EC2 configuration"
  type = object({
    instance_name = string
    instance_type = string
    ami           = string
  })
  default = {
    instance_name = "my-instance"
    instance_type = "t3.micro"
    ami           = "ami-0a357ea20d7b79c2c" # Amazon ECS-Optimized Amazon Linux 2023 (AL2023) x86_64 AMI
  }
}

variable "rds" {
  description = "RDS configuration"
  type = object({
    database_identifier = string
    database_name       = string
    db_user             = string
    db_pass             = string
  })
  default = {
    database_identifier = "my-database"
    database_name       = "production"
    db_user             = "postgres"
    db_pass             = "postgres"
  }
  sensitive = true
}

# S3 Bucket
variable "bucket_name" {
  description = "Name of S3 bucket"
  type        = string
  default     = "my-unique-bucket-kowan"
}

# ECR
variable "ecr_repository_name" {
  description = "Name of ECR repository"
  type        = string
  default     = "my-ecr-repo"
}

# ALB
variable "alb_name" {
  description = "Name of ALB"
  type        = string
  default     = "my-alb"
}

# Security Groups
variable "web_server_sg_name" {
  description = "Name of web server security group"
  type        = string
  default     = "my-web-server-sg"
}

variable "alb_sg_name" {
  description = "Name of ALB security group"
  type        = string
  default     = "my-alb-sg"
}


variable "service_sg_name" {
  description = "Name of ECS service security group"
  type        = string
  default     = "my-ecs-service-sg"
}

variable "rds_sg_name" {
  description = "Name of database security group"
  type        = string
  default     = "my-rds-sg"
}

# ECS
variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "ecs_capacity_provider_name" {
  description = "Name of ECS capacity provider"
  type        = string
  default     = "my-ecs-capacity-provider"
}

variable "task" {
  description = "Task configuration"
  type = object({
    name           = string,
    container_name = string,
    image          = string,
  })
  default = {
    name           = "my-task"
    container_name = "my-container"
    image          = "docker.io/nginx:latest"
  }
}

variable "ecs_service_name" {
  description = "Name of ECS Service"
  type        = string
  default     = "my-ecs-service"
}
