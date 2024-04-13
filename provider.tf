provider "vault" {
  address = "https://vault.rajdevops.online"
  skip_tls_verify = true
  token = var.vault_token
}