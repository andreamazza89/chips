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

module "persistence" {
  source = "../modules/persistence"

  environment = "${var.environment}"
  db_instance_name = "${var.db_instance_name}"
  db_name = "${var.db_name}"
  db_user_name = "${var.db_user_name}"
  db_password = "${var.db_password}"
  project_id = "${var.project_id}"
  region = "${var.region}"
}

module "computation" {
  source = "../modules/computation"

  environment = "${var.environment}"
  app_name = "${var.app_name}"
  db_instance_name = "${module.persistence.db_instance_name}"
  db_name = "${module.persistence.db_name}"
  db_user_name = "${module.persistence.db_user_name}"
  db_password = "${module.persistence.db_password}"
  network_tag = "${var.network_tag}"
  port = "${var.port}"
  project_id = "${var.project_id}"
  region = "${var.region}"
  zone = "${var.zone}"
}

module "network" {
  source = "../modules/network"

  environment = "${var.environment}"
  network_tag = "${var.network_tag}"
  project_id = "${var.project_id}"
}
