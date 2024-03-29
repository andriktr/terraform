variable "azure_ad_app_name" {
    description = "Name of the Azure AD Application to be created."
    type        = string
}
variable "azure_ad_app_owners" {
    description = "List of Azure AD User Principal Names (UPNs) to be added as owners of the Azure AD Application."
    type        = list(string)
}
variable "azure_ad_app_redirect_uri" {
    description = "Redirect URIs of the Azure AD Application."
    type        = list(string)
}
variable "azure_ad_app_access_token_issuance_enabled" {
    description = "Specifies whether this application supports access tokens via the OAuth 2.0 authorization code flow."
    type        = bool
}
variable "azure_ad_app_id_token_issuance_enabled" {
    description = "Specifies whether this application supports ID tokens via the OAuth 2.0 authorization code flow."
    type        = bool
}
variable "azure_ad_app_group_membership_claims" {
    description = "Specifies whether this application supports group membership claims"
    type        = list(string)
}
 