output "aks_public_ip" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "postgres_admin_user" {
  value = azurerm_postgresql_flexible_server.db.administrator_login
}

output "postgres_version" {
  value = azurerm_postgresql_flexible_server.db.version
}