variable "consul_datacenter" {
  description = "The name of the Consul datacenter to use."
  type = string
}
variable "acl_policy_name" {
  description = "The name of the ACL policy to create."
  type = string
}
variable "acl_policy_rules" {
  description = "The rules of the ACL policy to create."
  type = string
}

variable "acl_policy_description" {
  description = "The description of the ACL policy to create."
  type = string
}

variable "acl_role_name" {
  description = "The name of the ACL role to create."
  type = string
}
variable "acl_role_description" {
  description = "The description of the ACL role to create."
  type = string
}
variable "consul_auth_method_name" {
  description = "The name of the Consul auth method to use in binding rule."
  type = string
  default = "azure"
}

variable "binding_rule_description" {
  description = "The description of the binding rule to create."
  type = string
}

variable "binding_rule_name" {
  description = "The name of the binding rule to create."
  type = string
}

variable "aad_group_object_id" {
  description = "The AAD group object ID to use in binding rule. You can find this in the Azure Portal or retrieve it with the Azure CLI by running: az ad group show --group <group name> --query objectId --output tsv"
  type = string
}