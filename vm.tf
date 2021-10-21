resource "azurerm_storage_account" "rodrigo-stg" {
    name                        = "storagerodrigo"
    resource_group_name         = azurerm_resource_group.rodrigo.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Production"
    }

    depends_on = [ azurerm_resource_group.rodrigo ]
}

resource "azurerm_linux_virtual_machine" "rodrigo-lin-vm" {
    name                  = "rodrigomysql"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.rodrigo.name
    network_interface_ids = [azurerm_network_interface.rodrigo-int.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDiskMySQL"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "rodrigo-myvm"
    admin_username = "rodrigolsc"
    admin_password = "Rodrigo1310!"
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.rodrigo-stg.primary_blob_endpoint
    }

    depends_on = [ azurerm_resource_group.rodrigo ]
}

resource "time_sleep" "wait_30_seconds_db" {
  depends_on = [azurerm_linux_virtual_machine.rodrigo-lin-vm]
  create_duration = "30s"
}

resource "null_resource" "upload_db" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = "rodrigolsc"
            password = "Rodrigo1310!"
            host = data.azurerm_public_ip.rodrigo-ip-db.ip_address
        }
        source = "mysql"
        destination = "/home/rodrigolsc"
    }

    depends_on = [ time_sleep.wait_30_seconds_db ]
}

resource "null_resource" "deploy_db" {
    triggers = {
        order = null_resource.upload_db.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "rodrigolsc"
            password = "Rodrigo1310!"
            host = data.azurerm_public_ip.rodrigo-ip-db.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server",
            "sudo mysql < /home/rodrigolsc/mysql/script/user.sql",
            "sudo cp -f /home/rodrigolsc/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
            "sudo service mysql restart",
            "sleep 20",
        ]
    }
}      