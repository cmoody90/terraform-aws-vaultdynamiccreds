variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "db_name" {
  description = "The name of the database"
}

variable "username" {
  description = "The username for database access"
}

variable "password" {
  description = "The password for database access"
}
