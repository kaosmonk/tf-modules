variable "name" {
  default = "kraken-k8s"
}

variable "env" {
  default = "poc"
}
variable "node_count" {
  default = 1
}

variable "disk_size" {
  default = 10
}

variable "image_type" {
  default = "COS"
}

variable "max_node_count" {
  default = 3
}

variable "min_node_count" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "zone" {
  default = "us-west2-a"
}

variable "additional_zones" {
  default = [
    "us-west2-b",
    "us-west2-c",
  ]
}

variable "resource_labels" {
  default = {
      environment = "poc"
      cluster       = "kraken-poc-resource_label"
      terraform   = "true"
  }
}

variable "remote_state_bucket" {
  default = "kraken-tf-state"
}

variable "region" {
  default = "us-west2"
}

variable "project_id" {
  default = "kraken-221319"
}

variable "gke_version" {
  default = "1.10.7-gke.6"
}
