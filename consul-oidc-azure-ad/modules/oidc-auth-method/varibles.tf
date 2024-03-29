variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type = string
}

variable "consul_auth_method_name" {
  description = "The name of the Consul OIDC auth method to create."
  type = string
  default = "azure"
}
variable "consul_auth_method_description" {
  description = "The description of the Consul OIDC auth method to create."
  type = string
  default = "Azure AD OIDC auth method"
}

variable "consul_acl_auth_method_max_token_ttl" {
  description = "The maximum TTL for tokens created by this auth method."
  type = string
  default = "5m"
}

variable "consul_oidc_redirect_uri" {
  description = "The redirect URI to use for the Consul OIDC auth method."
  type =list(string)
}

variable "consul_oidc_client_id" {
  description = "The client ID to use for the Consul OIDC auth method. Can be retrievef with the Azure CLI: az ad sp list --display-name <app name> --query 'appId' -otsv"
  type = string
}

variable "consul_oidc_client_secret" {
  description = "The client secret to use for the Consul OIDC auth method."
  type = string
  #sensitive = true
}