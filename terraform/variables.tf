variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "key_name" {
  description = "sainath"
  type        = string
}

variable "dockerhub_user" {
  description = "DockerHub username with the published images"
  type        = string
}

variable "image_tag" {
  description = " Infrastructure and Automation"
  type        = string
  default     = "latest"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH "
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_cidr" {
  description = "CIDR allowed to access frontend (public)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
