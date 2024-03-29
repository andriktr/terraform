# Create Azure AD application configured for OpenID Connect
resource "azuread_application" "azure_ad_application" {
  display_name = var.azure_ad_app_name
  owners = var.azure_ad_app_owners
  group_membership_claims = var.azure_ad_app_group_membership_claims

  web {
    redirect_uris = var.azure_ad_app_redirect_uri
    
    implicit_grant {
      access_token_issuance_enabled = var.azure_ad_app_access_token_issuance_enabled
      id_token_issuance_enabled = var.azure_ad_app_id_token_issuance_enabled
    }
  }
  optional_claims {
    access_token {
      name = "groups"
      essential = false
      additional_properties = []
    }

    id_token {
      name                  = "groups"
      essential             = false
      additional_properties = []
    }

    saml2_token {
      name                  = "groups"
      essential             = false
      additional_properties = []
    }
  }
  required_resource_access {
    # Microsoft Graph API (User.Read and OpenId)
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
  }
}

# Create a service principal associated with Azure AD application
resource "azuread_service_principal" "azure_ad_application_service_principal" {
  application_id = azuread_application.azure_ad_application.application_id
  owners = var.azure_ad_app_owners
}

# Assign generated password to a service principal associated Azure AD application
resource "azuread_service_principal_password" "azure_ad_application_service_principal_password" {
  service_principal_id = azuread_service_principal.azure_ad_application_service_principal.id
  end_date             = "2030-01-01T01:02:03Z"
}
