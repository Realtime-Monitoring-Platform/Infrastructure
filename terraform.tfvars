location            = "westeurope"
resource_group_name = "rg-realtime-monitoring"
prefix              = "rtm"
mqtt_dns_label      = "mqtt-chedly-2026"
mqtt_vm_size        = "Standard_B2ats_v2"
aks_node_size       = "Standard_B2ats_v2"
aks_node_count      = 1
ssh_public_key = "C:/Users/User/Desktop/realtime_monitoring/infra/.ssh/id_rsa.pub"

postgres_admin_username = "postgres"
postgres_admin_password = "postgres"
postgres_databases = ["jwt", "device_management", "notification", "read_database", "tenant_management"]
