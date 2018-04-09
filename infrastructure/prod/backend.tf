terraform {
 backend "gcs" {
   bucket  = "chips-194714"
   prefix  = "prod/terraform.tfstate"
   project = "chips-194714"
 }
}
