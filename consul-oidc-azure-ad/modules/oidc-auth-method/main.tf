resource "consul_acl_auth_method" "oidc_auth_method" {
  name          = var.consul_auth_method_name
  type          = "oidc"
  description   = var.consul_auth_method_description
  max_token_ttl = var.consul_acl_auth_method_max_token_ttl

  config_json = jsonencode({
    "AllowedRedirectURIs": [var.consul_oidc_redirect_uri],
    "BoundAudiences": [var.consul_oidc_client_id],
    "OIDCClientID": var.consul_oidc_client_id,
    "OIDCClientSecret": var.consul_oidc_client_secret,
    "OIDCDiscoveryURL": "https://login.microsoftonline.com/${var.tenant_id}/v2.0",
    "ListClaimMappings": {
      "groups": "groups"
    }
  })
}