variable "environment" {}
variable "network_tag" {}
variable "project_id" {}

resource "google_compute_firewall" "default" {
    name    = "chips-firewall-${var.environment}"
    network = "default"
    project = "${var.project_id}"

    allow {
        protocol = "tcp"
        ports = ["80", "8000", "8080"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["${var.network_tag}-${var.environment}"]
}

