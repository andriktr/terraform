# Create Consul ACL Policy 
resource "consul_acl_policy" "oidc_policy" {
  datacenters = [var.consul_datacenter]
  name        = var.acl_policy_name
  description = var.acl_policy_description
  rules       = var.acl_policy_rules
}

# Create Consul ACL Role and Assign the Policy to it
resource "consul_acl_role" "oidc_role" {
  name        = var.acl_role_name
  description = var.acl_role_description
  policies    = [consul_acl_policy.oidc_policy.id]
}

# Create Consul ACL Binding rule
resource "consul_acl_binding_rule" "oidc_binding_rule" {
    auth_method = var.consul_auth_method_name
    description = var.binding_rule_description
    selector = "\"${var.aad_group_object_id}\" in list.groups"
    bind_type   = "role"
    bind_name   = var.binding_rule_name
}