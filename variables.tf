variable "location" {
    description = "Azure region "
    type = string
    default = "westeurope"
}

variable "ressource_group_name" {
    type = string
    default = "rg-realtime-monitoring"
}


variable "prefix" {
    type = string 
    default = "rtm"
}

variable "mqtt_vm_size" {
    type = string
    default = "Standard_B2ats_v2"
}

variable "aks_node_size" {
    type = string
    default = "Standard_B2ats_v2"
}

variable "aks_node_count" {
    type = number
    default =1
}

variable "ssh_public_key" {
    type = string
    default = "C:/Users/User/Desktop/realtime_monitoring/infra/.ssh/id_rsa.pub"
}

variable  "mqtt_dns_label" {
    type = string
    default = "mqtt-chedly-2026"
}