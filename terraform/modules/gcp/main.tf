terraform {
  backend "gcs" {}
}

provider "google" {
  #credentials = "${file("kraken-buildbot-sc-key.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}
