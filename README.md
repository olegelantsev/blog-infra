# Azure as IaC for blog
----

Blog is hosted on Azure Storage, distributed with Azure CDN.

## Setup

### Prerequisite

Terraform and Azure CLI are installed.

### Deploy

```bash
cd blog
terraform init
terraform apply -var-file=terraform.tfvars
```

### Renew certificate

Requires pre-deployed Azure Key Vault where certificate is uploaded.

```bash
cd acme
terraform init
terraform apply -var-file=terraform.tfvars
```
