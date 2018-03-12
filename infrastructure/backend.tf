terraform {
 backend "gcs" {
   bucket  = "chips-194714"
   prefix  = "/terraform.tfstate"
   project = "chips-194714"
 }
}
