variable "environment" {}
variable "db_instance_name" {}
variable "db_name" {}
variable "db_user_name" {}
variable "db_password" {}
variable "project_id" {}
variable "region" {}

resource "google_sql_database_instance" "chips-database-instance" {
  database_version = "POSTGRES_9_6"
  name             = "${var.db_instance_name}-${var.environment}"
  project          = "${var.project_id}"
  region           = "${var.region}"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "chips-database" {
  instance  = "${google_sql_database_instance.chips-database-instance.name}"
  name      = "${var.db_name}-${var.environment}"
  project   = "${var.project_id}"
}

resource "google_sql_user" "user" {
  name     = "${var.db_user_name}"
  instance = "${google_sql_database_instance.chips-database-instance.name}"
  host     = ""
  password = "${var.db_password}"
  project  = "${var.project_id}"
}

output "db_instance_name" {
  value = "google_sql_database_instance.chips-catabase-instance.name"
}

output "db_name" {
  value = "google_sql_database.chips-catabase.name"
}

output "db_user_name" {
  value = "google_sql_user.user.name"
}

output "db_password" {
  value = "google_sql_user.user.password"
}
