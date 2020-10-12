resource "google_compute_instance" "kdevops_instances" {
  count        = local.num_boxes
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
  machine_type = var.machine_type
  zone         = var.region

  tags = ["kdevops" ]

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  scratch_disk {
    interface = var.scratch_disk_interface
  }

  scratch_disk {
    interface = var.scratch_disk_interface
  }

  network_interface {
    network = "default"

    # Ephemeral IP
    access_config {
    }
  }

  metadata = {
    sshKeys = format("%s:%s", var.ssh_config_user, file(var.ssh_config_pubkey_file))
  }

  metadata_startup_script = "echo hi > /test.txt"
}
