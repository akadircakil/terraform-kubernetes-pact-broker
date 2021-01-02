variable "name" {}

variable "namespace" {}

variable "pact_broker_basic_auth_username" {}

variable "pact_broker_basic_auth_password" {}

variable "pact_broker_postgres_username" {
  default = "admin"
}

variable "pact_broker_postgres_password" {
  default = "admin"
}

variable "storage_class_name" {
  default = "standard"
}

variable "storage_size" {
  default = "1Gi"
}

