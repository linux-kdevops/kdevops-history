# Azure terraform provider main

resource "azurerm_resource_group" "fstests_group" {
  name     = "fstests_resource_group"
  location = "westus"

  tags = {
    environment = "fstests tests"
  }
}

resource "azurerm_virtual_network" "fstests_network" {
  name                = "fstestsNet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus"
  resource_group_name = azurerm_resource_group.fstests_group.name

  tags = {
    environment = "fstests tests"
  }
}

resource "azurerm_subnet" "fstests_subnet" {
  name                 = "fstestsSubnet"
  resource_group_name  = azurerm_resource_group.fstests_group.name
  virtual_network_name = azurerm_virtual_network.fstests_network.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "fstests_publicip" {
  count               = local.num_boxes
  name                = format("fstests_pub_ip_%02d", count.index + 1)
  location            = "westus"
  resource_group_name = azurerm_resource_group.fstests_group.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "fstests tests"
  }
}

resource "azurerm_network_security_group" "fstests_sg" {
  name                = "fstetsNetworkSecurityGroup"
  location            = "westus"
  resource_group_name = azurerm_resource_group.fstests_group.name

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
    environment = "fstests tests"
  }
}

resource "azurerm_network_interface" "fstests_nic" {
  count                     = local.num_boxes
  name                      = format("fstests_nic_%02d", count.index + 1)
  location                  = "westus"
  resource_group_name       = azurerm_resource_group.fstests_group.name
  network_security_group_id = azurerm_network_security_group.fstests_sg.id

  ip_configuration {
    name                          = "fstestsNicConfiguration"
    subnet_id                     = azurerm_subnet.fstests_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.fstests_publicip.*.id, count.index)
  }

  tags = {
    environment = "fstests tests"
  }
}

resource "random_id" "randomId" {
  count = local.num_boxes
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.fstests_group.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "fstests_storageaccount" {
  count                    = local.num_boxes
  name                     = "diag${element(random_id.randomId.*.hex, count.index)}"
  resource_group_name      = azurerm_resource_group.fstests_group.name
  location                 = "westus"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    environment = "fstests tests"
  }
}

resource "azurerm_virtual_machine" "fstests_vm" {
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
  location              = "westus"
  resource_group_name   = azurerm_resource_group.fstests_group.name
  network_interface_ids = [element(azurerm_network_interface.fstests_nic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    # Note: yes using the names like the ones below is better however it also
    # means propagating a hack *many* times. It would be better to instead
    # move this hack to a single place using local variables somehow so that
    # we can later adjust the hack *once* instead of many times.
    #name              = "${format("fstests-main-disk-%s", element(azurerm_virtual_machine.fstests_vm.*.name, count.index))}"
    name              = format("fstest-main-disk-%02d", count.index + 1)
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
    computer_name = replace(
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
    admin_username = var.ssh_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.ssh_username}/.ssh/authorized_keys"
      key_data = var.ssh_pubkey_data != "" ? var.ssh_pubkey_data : var.ssh_pubkey_file != "" ? file(var.ssh_pubkey_file) : ""
    }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = element(
      azurerm_storage_account.fstests_storageaccount.*.primary_blob_endpoint,
      count.index,
    )
  }

  tags = {
    environment = "fstests tests"
  }
}

