
output "azure_ad_application_id" {
  value = azuread_application.azure_ad_application.application_id
}

output "azure_ad_application_object_id" {
  value = azuread_application.azure_ad_application.object_id
}

output "azure_ad_application_service_principal_id" {
  value = azuread_service_principal.azure_ad_application_service_principal.id
}

output "azure_ad_application_service_principal_password" {
  value = azuread_service_principal_password.azure_ad_application_service_principal_password.value
}
