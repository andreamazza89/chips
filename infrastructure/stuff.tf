variable "project_id" {}
variable "region" {}
variable "zone" {}

resource "google_sql_database_instance" "chips-database" {
  database_version = "POSTGRES_9_6"
  name             = "chips-pips"
  project          = "${var.project_id}"
  region           = "${var.region}"

  settings {
    tier = "db-f1-micro"
  }

//////////////////////////////////
// ANDREA - this needs the database `chips_prod` to exist and a user for Postgrex to establish a connection
//   - database; can be setup programmatically, not sure about terraform (maybe can open a pull request?) https://cloud.google.com/sql/docs/postgres/create-manage-databases
//   - database; will there be a duplication of truth in terms of db name resolution? --> maybe the migrator should also create the database if not existent?
//   - user; this can be created with terraform but need to do it without revealing secrets and using the same credentials as used when building release
//////////////////////////////////
}

/*
resource "google_sql_user" "users" {
  name     = "test"
  instance = "${google_sql_database_instance.chips-database.name}"
  host     = ""
  password = "test-monkey"
  project  = "${var.project_id}"
}
*/

resource "google_compute_instance" "chips-instance" {
  depends_on                = ["google_sql_database_instance.chips-database"]
  project                   = "${var.project_id}"
  name                      = "chips"
  machine_type              = "f1-micro"
  allow_stopping_for_update = "true"
  zone                      = "${var.region}-${var.zone}"

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

// create table in database
// user??
// pull proxy
// run proxy (interpolate db connection name?): docker run -it -v /mnt/stateful_partition/cloudsql:/cloudsql -p 127.0.0.1:5432:5432 gcr.io/cloudsql-docker/gce-proxy:1.11 /cloud_sql_proxy -instances=chips-194714:europe-west2:chips-pips=tcp:0.0.0.0:5432

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
