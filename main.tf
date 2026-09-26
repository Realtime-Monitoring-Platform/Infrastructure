resource "azurerm_resource_group" "main" {
    name = var.resource_group_name
    location = var.location

    tags = {
        project = "realtime-monitoring"
        environment = "student-lab"
        lifetime = "2-weeks"
    }
}

resource "azurerm_virtual_network" "main" {
    name = "${var.prefix}-vnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "mqtt" {
    name = "mqtt-subnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "aks" {
    name = "aks-subnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.0.1.0/24"]
}


resource "azurerm_subnet" "postgres" {
    name = "postgres-subnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.0.3.0/24"]
    delegation {
    name = "postgres-flexible-server"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }

}
resource "azurerm_network_security_group" "mqtt" {
    name = "${var.prefix}-mqtt-nsg"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name = "Allow-MQTT-8883"
        priority = 100
        direction  = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "8883"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "Allow-SSH"
        priority = 110
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }
}

resource "azurerm_subnet_network_security_group_association" "mqtt" {
    subnet_id = azurerm_subnet.mqtt.id
    network_security_group_id = azurerm_network_security_group.mqtt.id
}

resource "azurerm_public_ip" "mqtt" {
    name = "${var.prefix}-mqtt-pip"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method = "Dynamic"
    sku = "Basic"

    domain_name_label = var.mqtt_dns_label

}
#role of NIC is to connect the vm to the subnet  
resource "azurerm_network_interface" "mqtt" {
  name                = "${var.prefix}-mqtt-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mqtt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mqtt.id
  }
}

resource "azurerm_private_dns_zone" "postgres" {
    name = "postgres.database.azure.com"
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
    name = "postgres-dns-link"
    resource_group_name = azurerm_resource_group.main.name
    private_dns_zone_name = azurerm_private_dns_zone.postgres.name
    virtual_network_id = azurerm_virtual_network.main.id
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${var.prefix}-postgres"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  version = "16"

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

  tags = {
    project     = "realtime-monitoring"
    environment = "student-lab"
    lifetime    = "2-weeks"
    role        = "postgresql"
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
    for_each = var.postgres_databases
    name = each.value
    server_id = azurerm_postgresql_flexible_server.main.id

    charset = "UTF8"
    collation = "en_US.UTF8"
}

resource "azurerm_linux_virtual_machine" "mqtt" {
    name = "${var.prefix}-mqtt-vm"
    resource_group_name = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    size = var.mqtt_vm_size
    admin_username = "azureuser"

    network_interface_ids = [
        azurerm_network_interface.mqtt.id
    ]
    admin_ssh_key {
      username= "azureuser"
      public_key= file(var.ssh_public_key)
    }
    os_disk {

        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb         = 30
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }

  tags = {
    role = "mqtt-broker"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
    name = "${var.prefix}-aks-cluster"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    dns_prefix = "${var.prefix}-aks"
    sku_tier = "Free"

    default_node_pool {
        name = "default"
        node_count = var.aks_node_count
        vm_size = var.aks_node_size
        vnet_subnet_id = azurerm_subnet.aks.id
        os_disk_size_gb = 50
    }

    identity {
        type = "SystemAssigned"
    }

    network_profile {
        network_plugin = "kubenet"
        load_balancer_sku = "standard"
        service_cidr = "10.1.0.0/16"
        dns_service_ip = "10.1.0.10"
    }

    tags = {
        project = "realtime-monitoring"
    }

}





