location            = "westeurope"
resource_group_name = "rg-realtime-monitoring"
prefix              = "rtm"
mqtt_dns_label      = "mqtt-chedly-2026"
mqtt_vm_size        = "Standard_B2ats_v2"
aks_node_size       = "Standard_B2ats_v2"
aks_node_count      = 1
ssh_public_key = "~/.ssh/id_rsa.pub"