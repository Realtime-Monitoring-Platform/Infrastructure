output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "mqtt_public_ip" {
  value = azurerm_public_ip.mqtt.ip_address
}

output "mqtt_fqdn" {
  value       = azurerm_public_ip.mqtt.fqdn
  description = "Free Azure DNS name → use this in your certificate SAN"
}

output "mqtt_private_ip" {
  value = azurerm_network_interface.mqtt.private_ip_address
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}


output "keyvault_name" {
  value = azurerm_key_vault.main.name
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.keyvault.client_id
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}