terraform {
 backend "gcs" {
   bucket  = "chips-194714"
   prefix  = "staging/terraform.tfstate"
   project = "chips-194714"
 }
}
