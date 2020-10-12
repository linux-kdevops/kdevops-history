# Azure terraform provider main

resource "azurerm_resource_group" "kdevops_group" {
  name     = "kdevops_resource_group"
  location = var.resource_location

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_virtual_network" "kdevops_network" {
  name                = "kdevops_net"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.kdevops_group.name

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_subnet" "kdevops_subnet" {
  name                 = "kdevops_subnet"
  resource_group_name  = azurerm_resource_group.kdevops_group.name
  virtual_network_name = azurerm_virtual_network.kdevops_network.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "kdevops_publicip" {
  count               = local.num_boxes
  name                = format("kdevops_pub_ip_%02d", count.index + 1)
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.kdevops_group.name
  allocation_method   = "Static"

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_network_security_group" "kdevops_sg" {
  name                = "kdevops_network_security_group"
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.kdevops_group.name

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

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_network_interface_security_group_association" "kdevops_sg_assoc" {
  count                     = local.num_boxes
  network_security_group_id = azurerm_network_security_group.kdevops_sg.id
  network_interface_id = element(azurerm_network_interface.kdevops_nic.*.id, count.index)
}

resource "azurerm_network_interface" "kdevops_nic" {
  count                     = local.num_boxes
  name                      = format("kdevops_nic_%02d", count.index + 1)
  location                  = var.resource_location
  resource_group_name       = azurerm_resource_group.kdevops_group.name

  ip_configuration {
    name                          = "kdevops_nic_configuration"
    subnet_id                     = azurerm_subnet.kdevops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.kdevops_publicip.*.id, count.index)
  }

  tags = {
    environment = "kdevops tests"
  }
}

resource "random_id" "randomId" {
  count = local.num_boxes
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.kdevops_group.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "kdevops_storageaccount" {
  count                    = local.num_boxes
  name                     = "diag${element(random_id.randomId.*.hex, count.index)}"
  resource_group_name      = azurerm_resource_group.kdevops_group.name
  location                 = var.resource_location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_linux_virtual_machine" "kdevops_vm" {
  count = local.num_boxes

  # As of terraform 0.11 there is no easy way to convert a list to a map
  # for the structure we have defined for the vagrant_boxes. We can use
  # split to construct a subjset list though, and then key in with the
  # target left hand value name we want to look for. On the last split we
  # call always uses the second element given its a value: figure, we want
  # the right hand side of this.
  #
  # The "%7D" is the lingering nagging trailing "}" at the end of the string,
  # we just remove it.
  name = replace(
    urlencode(
      element(
        split(
          "name: ",
          element(data.yaml_list_of_strings.list.output, count.index),
        ),
        1,
      ),
    ),
    "%7D",
    "",
  )
  location              = var.resource_location
  resource_group_name   = azurerm_resource_group.kdevops_group.name
  network_interface_ids = [element(azurerm_network_interface.kdevops_nic.*.id, count.index)]
  size                  = var.vmsize
  admin_username        = var.ssh_config_user
  disable_password_authentication = true

  os_disk {
    # Note: yes using the names like the ones below is better however it also
    # means propagating a hack *many* times. It would be better to instead
    # move this hack to a single place using local variables somehow so that
    # we can later adjust the hack *once* instead of many times.
    #name                 = "${format("kdevops-main-disk-%s", element(azurerm_virtual_machine.kdevops_vm.*.name, count.index))}"
    name                  = format("kdevops-main-disk-%02d", count.index + 1)
    caching               = "ReadWrite"
    storage_account_type  = var.managed_disk_type
    #disk_size_gb         = 64
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_ssh_key {
    username      = var.ssh_config_user
    public_key    = var.ssh_config_pubkey_file != "" ? file(var.ssh_config_pubkey_file) : ""
  }

  boot_diagnostics {
    storage_account_uri = element(
      azurerm_storage_account.kdevops_storageaccount.*.primary_blob_endpoint,
      count.index,
    )
  }

  tags = {
    environment = "kdevops tests"
  }
}

resource "azurerm_managed_disk" "kdevops_data_disk" {
  count                = local.num_boxes
  name                 = format("kdevops-data-disk-%02d", count.index + 1)
  location             = var.resource_location
  resource_group_name  = azurerm_resource_group.kdevops_group.name
  create_option        = "Empty"
  storage_account_type = var.managed_disk_type
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "kdevops_data_disk" {
  count                     = local.num_boxes
  managed_disk_id           = azurerm_managed_disk.kdevops_data_disk[count.index].id
  virtual_machine_id        = element(azurerm_linux_virtual_machine.kdevops_vm.*.id, count.index)
  caching                   = "None"
  write_accelerator_enabled = false
  lun                       = 0
}

resource "azurerm_managed_disk" "kdevops_scratch_disk" {
  count                = local.num_boxes
  name                 = format("kdevops-scratch-disk-%02d", count.index + 1)
  location             = var.resource_location
  resource_group_name  = azurerm_resource_group.kdevops_group.name
  create_option        = "Empty"
  storage_account_type = var.managed_disk_type
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "kdevops_scratch_disk" {
  count                     = local.num_boxes
  managed_disk_id           = azurerm_managed_disk.kdevops_scratch_disk[count.index].id
  virtual_machine_id        = element(azurerm_linux_virtual_machine.kdevops_vm.*.id, count.index)
  caching                   = "None"
  write_accelerator_enabled = false
  lun                       = 1
}
