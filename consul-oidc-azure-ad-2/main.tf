#Loading modules which will create the Azure AD App and the Consul OIDC Auth Binding

data "azurerm_client_config" "current" {}

module "demo_azure_ad_app_for_oidc" {
  source = "./modules/azure-ad-app-for-oidc"
  azure_ad_app_name = "consul-oidc-demo-aad-app"
  azure_ad_app_owners = [
    "00000000-0000-0000-0000-000000000000",
    "00000000-0000-0000-0000-000000000000"
  ]
  
  azure_ad_app_redirect_uri = [
    "https://localhost:8501/ui/oidc/callback",
    "http://localhost:8550/oidc/callback" 
    ]
  azure_ad_app_access_token_issuance_enabled = true
  azure_ad_app_id_token_issuance_enabled = true
  azure_ad_app_group_membership_claims = ["All"]
}

# Loading modules which will enable the Consul OIDC Auth method 
# configured with Azure AD identity provider
module "demo_oidc_auth_method" {
  source = "./modules/oidc-auth-method"
  consul_auth_method_name = "azure"
  consul_auth_method_description = "Azure AD OIDC Auth Method"
  consul_acl_auth_method_max_token_ttl = "15m"
  consul_oidc_redirect_uri = [ 
    "https://localhost:8501/ui/oidc/callback",
    "http://localhost:8550/oidc/callback"
  ]
  tenant_id = data.azurerm_client_config.current.tenant_id
  # If you loading azure_ad_app_for_oidc module and want to use the client_id and client_secret created by it 
  # you can specify as follows: 
  #consul_oidc_client_id = module.demo_azure_ad_app_for_oidc.azure_ad_application_id
  #consul_oidc_client_secret = module.demo_azure_ad_app_for_oidc.azure_ad_application_service_principal_password
  # If you want to use your own precreates Azure AD App you can specify as follows:
  consul_oidc_client_id = "00000000-0000-0000-0000-000000000000"
  consul_oidc_client_secret = "00000000-0000-0000-0000-000000000000"
}


# Loading modules which will create the Consul ACL Policy 
# and the Consul ACL Role and bind them together after that
# the ACL role will be attached to the Consul OIDC Auth method
module "demo_oidc_auth_binding" {
  source = "./modules/oidc-auth-binding"
  consul_datacenter = var.consul_datacenter
  acl_policy_name = "basic-readers-demo-policy"
  acl_policy_description = "Basic Readers Policy created for demo purposes. Created with Terraform."
  acl_policy_rules = <<-EOF
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    EOF
  acl_role_name = "basic-readers-demo-role"
  acl_role_description = "Basic Readers Role created for demo purposes. Created with Terraform."
  consul_auth_method_name = "azure"
  binding_rule_description = "Basic Readers Binding Rule created for demo purposes. Created with Terraform."
  binding_rule_name = "basic-readers-demo-binding-rule"
  aad_group_object_id = "00000000-0000-0000-0000-000000000000"
}

