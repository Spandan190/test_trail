variable "project_id" {
  description = "project ID"
  type        = string
}

variable "region" {
  description = "region to deploy"
  type        = string
}

variable "database_name" {
  description = "name of database"
  type        = string
}

variable "container_image" {
  description = "container image to deploy"
  type        = string
}