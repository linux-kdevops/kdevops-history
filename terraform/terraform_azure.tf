resource "azurerm_resource_group" "fstests_group" {
    name     = "fstests_resource_group"
    location = "westus"

    tags {
        environment = "fstests tests"
    }
}

resource "azurerm_virtual_network" "fstests_network" {
    name                = "fstestsNet"
    address_space       = ["10.0.0.0/16"]
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.fstests_group.name}"

    tags {
        environment = "fstests tests"
    }
}

resource "azurerm_subnet" "fstests_subnet" {
    name                 = "fstestsSubnet"
    resource_group_name  = "${azurerm_resource_group.fstests_group.name}"
    virtual_network_name = "${azurerm_virtual_network.fstests_network.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "fstests_publicip" {
    name                         = "fstestPublicIP"
    location                     = "westus"
    resource_group_name          = "${azurerm_resource_group.fstests_group.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "fstests tests"
    }
}

resource "azurerm_network_security_group" "fstests_sg" {
    name                = "fstetsNetworkSecurityGroup"
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.fstests_group.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "fstests tests"
    }
}

resource "azurerm_network_interface" "fstests_nic" {
    name                = "fstestsNIC"
    location            = "westus"
    resource_group_name = "${azurerm_resource_group.fstests_group.name}"
    network_security_group_id = "${azurerm_network_security_group.fstests_sg.id}"

    ip_configuration {
        name                          = "fstestsNicConfiguration"
        subnet_id                     = "${azurerm_subnet.fstests_subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.fstests_publicip.id}"
    }

    tags {
        environment = "fstests tests"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.fstests_group.name}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "fstests_storageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.fstests_group.name}"
    location            = "westus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "fstests tests"
    }
}

resource "azurerm_virtual_machine" "fstests_vm" {
    name                  = "fstests_vm_1"
    location              = "westus"
    resource_group_name   = "${azurerm_resource_group.fstests_group.name}"
    network_interface_ids = ["${azurerm_network_interface.fstests_nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "fstestsOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "credativ"
        offer     = "Debian"
        sku       = "9"
        version   = "latest"
    }

    os_profile {
        computer_name  = "oscheck-xfs"
        admin_username = "${var.ssh_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.ssh_username}/.ssh/authorized_keys"
            key_data = "${var.ssh_pubkey_data}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.fstests_storageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "fstests tests"
    }
}

output "master_ip_address" {
  value = "${azurerm_public_ip.fstests_publicip.ip_address}"
}
