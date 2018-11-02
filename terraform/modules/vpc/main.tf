terraform {
  backend "gcs" {}
}

provider "google" {
}

resource "google_compute_network" "vpc" {
  name                    = "${var.name}-${var.env}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-${var.env}-subnet"
  ip_cidr_range = "${var.subnet_cidr}"
  network       = "${var.name}-${var.env}-vpc"
  depends_on    = ["google_compute_network.vpc"]
  region        = "${var.region}"
}

resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}
