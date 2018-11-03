terraform {
  backend "gcs" {}
}

provider "google" {
}

provider "random" {}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "sql-"
}

resource "random_id" "user-password" {
  byte_length = 8
}

resource "google_sql_database_instance" "master" {
  name             = "kraken-master-${random_id.id.hex}"
  region           = "${var.region}"
  database_version = "MYSQL_5_7"

  settings {
    availability_type = "${var.availability_type}"
    tier              = "${var.sql_instance_size}"
    disk_type         = "${var.sql_disk_type}"
    disk_size         = "${var.sql_disk_size}"
    disk_autoresize   = true

    ip_configuration {
      authorized_networks = {
        value = "0.0.0.0/0"
      }

      require_ssl  = "${var.sql_require_ssl}"
      ipv4_enabled = true
    }

    location_preference {
      zone = "${var.region}-${var.sql_master_zone}"
    }

    backup_configuration {
#      binary_log_enabled = true
      enabled            = true
      start_time         = "00:00"
    }
  }
}

resource "google_sql_database_instance" "replica" {
  depends_on = [
    "google_sql_database_instance.master",
  ]

  name                 = "kraken-replica"
  count                = "1"
  region               = "${var.region}"
  database_version     = "MYSQL_5_7"
  master_instance_name = "${google_sql_database_instance.master.name}"

  settings {
    tier            = "${var.sql_instance_size}"
    disk_type       = "${var.sql_disk_type}"
    disk_size       = "${var.sql_disk_size}"
    disk_autoresize = true

    location_preference {
      zone = "${var.region}-${var.sql_replica_zone}"
    }
  }
}

resource "google_sql_user" "user" {
  depends_on = [
    "google_sql_database_instance.master",
    "google_sql_database_instance.replica",
  ]

  instance = "${google_sql_database_instance.master.name}"
  name     = "${var.sql_user}"
  password = "${random_id.user-password.hex}"
}
