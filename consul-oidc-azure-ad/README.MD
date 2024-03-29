# Terraform modules to configure authentication with OIDC and Azure AD for Consul Enterprise

![Logo](./images/Logo.png "Logo")

## Table of Contents

* [Description](#description)
* [Prerequisites](#prerequisites)
* [Configuration](#configuration)
  * [Modules](#modules)
  * [Variables](#variables)
    * [Variables for root module](#variables-for-root-module)
    * [Variables for azure-ad-app-for-oidc module](#variables-for-azure-ad-app-for-oidc-module)
    * [Variables for oidc-auth-method module](#variables-for-oidc-auth-method-module)
    * [Variables for oidc-auth-binding module](#variables-for-oidc-auth-binding-module)
* [Deployment](#deployment)
* [Usage](#usage)
* [Cleanup](#cleanup)
* [Useful Documentation](#useful-documentation)

## Description

Repository contains Terraform modules to configure OIDC authentication method in Consul Enterprise using Azure AD as an identity provider.

## Prerequisites

* OIDC authentication is supported in Consul Enterprise only. Version 1.8.0 or later is required.
* Make sure you have appropriate permissions to create Azure AD applications and service principals.
* Admin consent is required for the application to access the Microsoft Graph API. This is required for the application to be able to read the user's profile information. The admin consent can be granted by an Azure AD global administrator or by a user with the Global Administrator role assigned in the Azure portal.
* Current configuration allows bind Azure AD groups to Consul ACL roles. Role will have a policy attached to it. Make sure you have appropriate permissions to create Azure AD security groups and ensure that token used to authenticate to Consul during the deployment has permissions to create ACL policies and roles.

## Configuration

### Modules

Solution contains the following modules:

* [root module](./main.tf) - loads other modules and sets variables for them.
* [azure-ad-app-for-oidc](./modules/azure-ad-app-for-oidc) - creates Azure AD application and service principal which will be used to configure OIDC authentication method in Consul.
* [oidc-auth-method](./modules/oidc-auth-method) - module to configure Consul OIDC authentication method.
* [oidc-auth-binding](./modules/oidc-auth-binding) - module used to bind Consul OIDC authentication method with ACL role and AAD group.

### Variables

#### Variables for root module

Variables for root module are defined in [variables.tf](./variables.tf) file and used in [main.tf](./main.tf) file. By default [variables.tf](./variables.tf) file contains variables required for consul terraform provider. However you may want to have a single `main.tf` file and deploy it with different with values specific to particular environment. For this you can add required variables to [variables.tf](./variables.tf) and create separate `variables.tfvars` file for each environment in [environments](./environments) folder. `variables.tfvars` file should contain values for variables defined in [variables.tf](./variables.tf) file (if default value is not set). Then when you loading modules in [main.tf](./main.tf) instead of setting values for variables directly you can pass you can set them as a variable from [variables.tf](./variables.tf) file. Typically `variables.tfvars` file contains only values for variables which are specific to particular environment.

Here is an example of how loaded module variables values are set directly in [main.tf](./main.tf) file:

```hcl
module "demo_azure_ad_app_for_oidc" {
  source = "./modules/azure-ad-app-for-oidc"
  azure_ad_app_name = "consul-oidc-demo-aad-app"
  azure_ad_app_owners = []
  azure_ad_app_redirect_uri = []
  azure_ad_app_access_token_issuance_enabled = true
  azure_ad_app_id_token_issuance_enabled = true
  azure_ad_app_group_membership_claims = ["All"]
}
```

Here is an example of how to pass values from variables defined in [variables.tf](./variables.tf) and `variables.tfvars` files:

```hcl
module "demo_azure_ad_app_for_oidc" {
  source = "./modules/azure-ad-app-for-oidc"
  azure_ad_app_name = var.azure_ad_app_name # 
  azure_ad_app_owners = var.azure_ad_app_owners 
  azure_ad_app_redirect_uri = var.azure_ad_app_redirect_uri
  azure_ad_app_access_token_issuance_enabled = var.azure_ad_app_access_token_issuance_enabled
  azure_ad_app_id_token_issuance_enabled = var.azure_ad_app_id_token_issuance_enabled
  azure_ad_app_group_membership_claims = var.azure_ad_app_group_membership_claims
}
```

Using this approach requires you to pass `-var-file` parameter to `terraform plan` and `terraform apply` commands. See deployment section for more details.

Name | Description | Type |
---- | ----------- | ---- |
consul_url | The URL of the Consul server to use. | string |
consul_token | The Consul ACL token to use. Requires high-privilege token as it is used to create ACL policies and roles. | string |
consul_datacenter | The Consul datacenter to use. | string |

#### Variables for azure-ad-app-for-oidc module

Name | Description | Type |
---- | ----------- | ---- |
azure_ad_app_name | Name of the Azure AD Application to be created and used for OIDC authentication. | string
azure_ad_app_owners | List of object IDs of Azure AD users or groups who will be owners of the Azure AD Application. You can retrieve ID of a user or group from Azure portal or using Azure CLI by running `az ad user show --id <user_principal_name> --query id -otsv or` or `az ad group show --group <group_name> --query "id" -o tsv`. | list(string)
azure_ad_app_redirect_uri | List of redirect URIs where the response to the authorization request can be sent and received by the Azure AD application. For example: "http://localhost:8550/oidc/callback","http://localhost:8500/ui/oidc/callback"
azure_ad_app_access_token_issuance_enabled | Specifies whether this app can request an access token using the OAuth 2.0 authorization code flow. Typically should be set to `true` | bool
azure_ad_app_id_token_issuance_enabled | Specifies whether this app can request an ID token using the OAuth 2.0 authorization code flow. Typically should be set to `true` | bool
azure_ad_app_group_membership_claims | Specifies whether this app supports group membership claims. | list(string)

#### Variables for oidc-auth-method module

Name | Description | Type |
---- | ----------- | ---- |
tenant_id | The tenant ID of the Azure AD tenant in which the Azure AD application was created. | string |
consul_auth_method_name | Name of the Consul OIDC authentication method. Defaults to `azure` | string |
consul_auth_method_description | Description of the Consul OIDC authentication method. Defaults to `Azure OIDC authentication method` | string
consul_acl_auth_method_max_token_ttl | The maximum allowed lifetime of tokens issued using this auth method. Defaults to `5m` | string
consul_oidc_client_id | The client ID to use for the Consul OIDC auth method. Can be retrieved with the Azure CLI: `az ad sp list --display-name <app name> --query 'appId' -otsv`| string
consul_oidc_client_secret | The client secret to use for the Consul OIDC auth method | string
consul_oidc_redirect_uri | The redirect URI to use for the Consul OIDC auth method | list(string)

#### Variables for oidc-auth-binding module

Name | Description | Type |
---- | ----------- | ---- |
consul_datacenter | The Consul datacenter to use. | string
acl_policy_name | Name of the ACL policy to be created and attached to the role. | string
acl_policy_rules | Rules of the ACL policy to be created and attached to the role. Make sure to use correct syntax [Consul ACL Policy Rules](https://developer.hashicorp.com/consul/docs/security/acl/acl-rules) | string
acl_policy_description | Description of the ACL policy to be created and attached to the role. | string
acl_role_name | Name of the ACL role to be created and attached to the Azure AD group. | string
acl_role_description | Description of the ACL role to be created and attached to the Azure AD group. | string
consul_auth_method_name | Name of the Consul OIDC authentication method. Defaults to `azure` | string
binding_rule_name | Name of the binding rule to be created. | string
binding_rule_description | Description of the binding rule to be created. | string
aad_group_object_id | "The AAD group object ID to use in binding rule. You can find this in the Azure Portal or retrieve it with the Azure CLI by running: `az ad group show --group <group name> --query objectId --output tsv"` | string

## Deployment

For demo purposes our [main.tf](./main.tf) loads all three modules and sets values for their variables directly. In order to have single main.tf file for all environments you can create separate `variables.tfvars` files in the [environments](./environments) folder and pass them to [main.tf](./main.tf) module. This approach allows you to set different values for variables in different environments and have a single `main.tf` file.
In order to deploy the solution you need to run the following commands:

If simply setting values for module variables in [main.tf](./main.tf) file:

```bash
# Initialize Terraform
terraform init
# Plan the deployment
terraform plan 
# Apply configuration
terraform apply
```

If using approach with `variables.tfvars` files assuming you are deploying to `dev` environment:

```bash
terraform init 
terraform plan -var-file=environments/dev/variables.tfvars
terraform apply -var-file=environments/dev/variables.tfvars
```

## Usage

Once the module is deployed AAD group members will be able to authenticate to Consul using OIDC and will be able to access resources based on the ACL policy attached to the role. Here is the step-by-step guide on how to login to Consul UI using OIDC and Azure AD:

1. Navigate to the Consul UI and click on the "Login" button:

![Login step 1](./images/Login-1.jpg "Login step 1")

2. Then select SSO option and enter `default` in partition field and click OK:

![Login step 2](./images/Login-2.jpg "Login step 2")

3. Click on the "Continue with azure" button:

![Login step 3](./images/Login-3.jpg "Login step 3")

4. On the next screen you will be redirected to the Azure AD login page or you will be logged into consul automatically if you are already logged in.

P.S.
If you want to login as a different other than the one you are currently logged without logging it out you can start your browser in incognito/private mode and login as a different user.

P.P.S.
Token expiration time is set to 5 minutes by default. If you are not using the token for 5 minutes it will expire and you will need to login again.

## Cleanup

To destroy the resources run the following commands:

If simply setting values for module variables in [main.tf](./main.tf) file:

```bash
# Initialize Terraform
terraform init
# Plan the deployment
terraform plan -destroy
# Apply configuration
terraform destroy
```

If using approach with `variables.tfvars` files assuming you are deploying to `dev` environment:

```bash
terraform init 
terraform plan -destroy -var-file=environments/dev/variables.tfvars
terraform destroy -var-file=environments/dev/variables.tfvars
```

## Useful Documentation

[OpenID Connect (OIDC) Auth Method](https://developer.hashicorp.com/consul/docs/security/acl/auth-methods/oidc)

[Authenticate Users with Single Sign-On (SSO) and Auth0](https://developer.hashicorp.com/consul/tutorials/datacenter-operations/single-sign-on-auth0)

[Consul ACL Policy Rules](https://developer.hashicorp.com/consul/docs/security/acl/acl-rules)