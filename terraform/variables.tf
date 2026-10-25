variable "aws_region" {
  description = "AWS region for this assignment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short resource name prefix"
  type        = string
  default     = "travelmemory"
}

variable "key_name" {
  description = "Existing EC2 key pair name in ap-south-1 (name only, not the PEM path)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your current public IPv4 CIDR for SSH, e.g. 203.0.113.10/32"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.my_ip_cidr))
    error_message = "Set your current public IPv4 address with /32, for example 203.0.113.10/32."
  }
}

variable "web_instance_type" {
  description = "EC2 type for the web/app server"
  type        = string
  default     = "t3.small"
}

variable "db_instance_type" {
  description = "EC2 type for the private database server"
  type        = string
  default     = "t3.micro"
}

variable "volume_size_gb" {
  description = "Root EBS volume size"
  type        = number
  default     = 12
}

variable "availability_zone" {
  description = "Availability zone; ap-south-1a is used by default"
  type        = string
  default     = "ap-south-1a"
}
