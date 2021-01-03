# terraform-kubernetes-pact-broker

Pack Broker Terraform Module For Kubernetes

## Required Inputs

- name `string`
- namespace `string`
- pact_broker_basic_auth_password `string`
- pact_broker_basic_auth_username `string`

## Optional Inputs

- pact_broker_postgres_username `string`
- pact_broker_postgres_password `string`
- storage_class_name `string`
- storage_size `string`

## Usage

```hcl
module "pact-broker" {
  source  = "akadircakil/pact-broker/kubernetes"
  version = "0.0.1"

  name                            = "pact-broker"
  namespace                       = "dev"
  pact_broker_basic_auth_username = "admin"
  pact_broker_basic_auth_password = "123"
}
```

```hcl
module "pact-broker" {
  source  = "akadircakil/pact-broker/kubernetes"
  version = "0.0.1"

  name                            = "pact-broker"
  namespace                       = "dev"
  pact_broker_basic_auth_username = "admin"
  pact_broker_basic_auth_password = "123"
  pact_broker_postgres_username   = "admin"
  pact_broker_postgres_password   = "123"
  storage_class_name              = "standard"
  storage_size                    = "1Gi"
}
```
