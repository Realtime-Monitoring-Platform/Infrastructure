location            = "switzerlandnorth"
resource_group_name = "rg-realtime-monitoring"
prefix              = "rtm"
mqtt_dns_label      = "mqtt-chedly-2026"
mqtt_vm_size        = "Standard_B2ats_v2"
aks_node_size       = "Standard_D4s_v3"
aks_node_count      = 1
ssh_public_key      = "C:/Users/User/Desktop/realtime_monitoring/infra/.ssh/id_rsa.pub"
subscription_id     = "a28ea085-6eee-4f76-bea9-251538f544b3"


ssh_allowed_cidr        = "197.6.47.25/32"
postgres_admin_username = "postgres"
postgres_admin_password = "postgres"

postgres_databases = ["jwt", "ai_analysis_db",
  "notification",
  "device_management",
  "read_database",
"tenant_mang"]
