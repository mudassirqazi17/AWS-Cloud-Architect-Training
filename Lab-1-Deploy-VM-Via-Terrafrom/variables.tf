variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "Name of AWS EC2 Key Pair for SSH login"
  type        = string
}

variable "instance_type" {
  description = "EC2 machine type"
  type        = string
  default     = "m5.xlarge" # 8 vCPU, 32GB RAM recommended for Kafka
}

