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

module "core" {
  source = "../modules"

  environment = "${var.environment}"
  app_name = "${var.app_name}"
  db_instance_name = "${var.db_instance_name}"
  db_name = "${var.db_name}"
  db_user_name = "${var.db_user_name}"
  db_password = "${var.db_password}"
  network_tag = "${var.network_tag}"
  port = "${var.port}"
  project_id = "${var.project_id}"
  region = "${var.region}"
  zone = "${var.zone}"
}
