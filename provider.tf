provider "vault" {
  address = "https://vault-internal.rajdevops.online"
  skip_tls_verify = true
  token = var.vault_token
}