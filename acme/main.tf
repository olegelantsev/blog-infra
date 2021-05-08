terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "azurerm" {
  features {}
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = var.email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "www.${var.domain}"
  subject_alternative_names = ["www2.${var.domain}"]

  dns_challenge {
    provider = "cloudflare"
  }
}

data "azurerm_key_vault" "vault" {
  name                = var.vault_name
  resource_group_name = var.vault_resource_group
}

resource "azurerm_key_vault_certificate" "certificate_to_vault" {
  name         = replace(lower(var.domain), ".", "-")
  key_vault_id = data.azurerm_key_vault.vault.id

  certificate {
    contents = acme_certificate.certificate.certificate_p12
    password = acme_certificate.certificate.certificate_p12_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "EmailContacts"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    } 
  }
}

resource "local_file" "foo" {
  content  = acme_certificate.certificate.certificate_p12
  filename = "${path.module}/certificate.p12"
}