// TODO: setup service account for CircleCI and output secret (possibly base64 encoded?) for upload to circleCi
// This account is to have compute instance admin and storage admin rights

variable "environment" {}
variable "app_name" {}
variable "db_instance_name" {}
variable "db_name" {}
variable "db_user_name" {}
variable "db_password" {}
variable "network_tag" {}
variable "port" {}
variable "project_id" {}
variable "region" {}
variable "zone" {}

resource "google_compute_instance" "chips-instance" {
  project                   = "${var.project_id}"
  name                      = "${var.app_name}-${var.environment}"
  machine_type              = "f1-micro"
  allow_stopping_for_update = "true"
  zone                      = "${var.region}-${var.zone}"
  tags                      = ["${var.network_tag}-${var.environment}"]

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
      env:
        - name: DB_NAME
          value: "${var.db_name}"
        - name: DB_PASSWORD
          value: "${var.db_password}"
        - name: DB_USER_NAME
          value: "${var.db_user_name}"
        - name: MIX_ENV
          value: "${var.environment}"
        - name: PORT
          value: "${var.port}"
      name: chips
      stdin: false
      tty: false
  restartPolicy: Always
EOF
  }

/////// for some reason the multiline script doesn't seem to work - need to try again
///////
  metadata_startup_script = "docker pull gcr.io/cloudsql-docker/gce-proxy:1.11 && docker run -d -v /mnt/stateful_partition/cloudsql:/cloudsql -p 127.0.0.1:5432:5432 gcr.io/cloudsql-docker/gce-proxy:1.11 /cloud_sql_proxy -instances=${var.project_id}:${var.region}:${var.db_instance_name}=tcp:0.0.0.0:5432"

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
