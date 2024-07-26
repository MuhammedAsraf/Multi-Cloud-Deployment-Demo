resource "google_compute_network" "demo" {
    name = "demo-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "demo" {
    name = "demo-subnetwork"
    ip_cidr_range = "10.0.0.0/24"
    region = "us-east1"
    network = google_compute_network.demo.self_link
}

resource "google_compute_firewall" "demo" {
    name = "demo-firewall"
    network = google_compute_network.demo.self_link

    allow {
      protocol = "tcp"
      ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]  
}

resource "google_compute_instance" "demo" {
    name = "demo-instance"
    machine_type = "f1-micro"

    boot_disk {
initialize_params {
image = "debian-cloud/debian-12"
}
}

    network_interface {
      subnetwork = google_compute_subnetwork.demo.self_link

      access_config {
        // Ephemeral IP
        
      }
    }
    metadata = {
        ssh_keys = file("~/.ssh/id_rsa.pub")
    }
  
}
