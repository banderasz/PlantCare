terraform {
  required_version = "~>1.7.5"
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.25.0"
    }
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.tf_service_account
}