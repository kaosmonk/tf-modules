terraform {
  backend "gcs" {}
}

provider "google" {
}

data "google_container_registry_repository" "registry" {
  project = "${var.project_id}"
}

data "google_container_engine_versions" "region" {
  region = "${var.region}"
  project = "${var.project_id}"
}

data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config {
    bucket         = "${var.remote_state_bucket}"
    prefix         = "vpc/terraform.tfstate"
    region         = "${var.region}"
    project        = "${var.project_id}"
  }
}

resource "google_container_node_pool" "primary_pool" {
  name       = "${var.name}-${var.env}-pool"
  region       = "${var.region}"
  node_count = "${var.node_count}"
  cluster    = "${google_container_cluster.primary.name}"

  node_config {
    disk_size_gb    = "${var.disk_size}"
    image_type      = "${var.image_type}"
    machine_type    = "${var.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/pubsub",
    ]
  }

  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_cluster" "primary" {
  name                     = "${var.name}-${var.env}-cluster"
  region                     = "${var.region}"
  network                  = "${data.terraform_remote_state.vpc.vpc_name}"
  subnetwork               = "${data.terraform_remote_state.vpc.vpc_subnet_name}"
  #additional_zones         = "${var.additional_zones}"
  initial_node_count = 1
  remove_default_node_pool = true
  min_master_version       = "${data.google_container_engine_versions.region.latest_master_version}"
  node_version             = "${data.google_container_engine_versions.region.latest_node_version}"

  # Cluster labels
  resource_labels = "${var.resource_labels}"

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}
