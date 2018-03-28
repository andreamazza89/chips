// TODO: setup service account for CircleCI and output secret (possibly base64 encoded?) for upload to circleCi
// This account is to have compute instance admin and storage admin rights

variable "environment" {}
variable "db_instance_name" {}
variable "db_name" {}
variable "db_user_name" {}
variable "db_password" {}
variable "network_tag" {}
variable "project_id" {}
variable "region" {}
variable "zone" {}


resource "google_sql_database_instance" "chips-database-instance" {
  database_version = "POSTGRES_9_6"
  name             = "${var.db_instance_name}-${var.environment}"
  project          = "${var.project_id}"
  region           = "${var.region}"

  settings {
    tier = "db-f1-micro"
  }
}

//////////////////////////////////
// ANDREA - this needs the database `chips_prod` to exist and a user for Postgrex to establish a connection
//   - database; will there be a duplication of truth in terms of db name resolution? --> maybe the migrator should also create the database if not existent?
//   - user; another duplication of truth
//////////////////////////////////

resource "google_sql_database" "chips-database" {
  instance  = "${google_sql_database_instance.chips-database-instance.name}"
  name      = "${var.db_name}-${var.environment}"
  project   = "${var.project_id}"
}

resource "google_sql_user" "users" {
  name     = "${var.db_user_name}"
  instance = "${google_sql_database_instance.chips-database-instance.name}"
  host     = ""
  password = "${var.db_password}"
  project  = "${var.project_id}"
}

resource "google_compute_instance" "chips-instance" {
  depends_on                = ["google_sql_database_instance.chips-database-instance"]
  project                   = "${var.project_id}"
  name                      = "chips-${var.environment}"
  machine_type              = "f1-micro"
  allow_stopping_for_update = "true"
  zone                      = "${var.region}-${var.zone}"
  tags                      = ["${var.network_tag}"]

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/cos-cloud/global/images/cos-stable-64-10176-62-0"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

	metadata {
    gce-container-declaration = <<EOF
spec:
  containers:
    - image: 'gcr.io/chips-194714/chips-app:v1'
      name: chips
      stdin: false
      tty: false
  restartPolicy: Always
EOF
  }

/////// for some reason the multiline script doesn't seem to work - need to try again
///////
  metadata_startup_script = "docker pull gcr.io/cloudsql-docker/gce-proxy:1.11 && docker run -d -v /mnt/stateful_partition/cloudsql:/cloudsql -p 127.0.0.1:5432:5432 gcr.io/cloudsql-docker/gce-proxy:1.11 /cloud_sql_proxy -instances=${var.project_id}:${var.region}:${google_sql_database_instance.chips-database-instance.name}=tcp:0.0.0.0:5432"

//////////////////////////////////
// ANDREA - once you have a stable solution, see if you can trim these down; or better, create a new service account just for
// this service, with as few permissions as possible
//////////////////////////////////

  service_account {
    scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append",
        "https://www.googleapis.com/auth/sqlservice.admin"
    ]
  }
}

resource "google_compute_firewall" "default" {
    name    = "chips-firewall"
    network = "default"
    project = "${var.project_id}"

    allow {
        protocol = "tcp"
        ports = ["80", "8000", "8080"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["${var.network_tag}"]
}
