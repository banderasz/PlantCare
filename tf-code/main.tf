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

resource "google_container_cluster" "k8s_cluster" {
  name     = "k8s-cluster"
  location = var.region

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
    disk_size_gb = 30
    preemptible  = true
  }

  initial_node_count       = 1
  remove_default_node_pool = true
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
}

resource "google_container_node_pool" "eureka_pool" {
  name       = "eureka-pool"
  location   = var.region
  cluster    = google_container_cluster.k8s_cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
    disk_size_gb = 30
  }
}
data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.k8s_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.k8s_cluster.master_auth[0].cluster_ca_certificate, )
}

resource "kubernetes_deployment" "eureka_server" {
  metadata {
    name = "eureka-server"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "eureka-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "eureka-server"
        }
      }

      spec {
        container {
          image = "gcr.io/plantcare-420709/eureka-server:latest"
          name  = "eureka-server"

          port {
            container_port = 8761
          }
        }
      }
    }
  }
}

data "google_service_account" "terraform-sa" {
  account_id = "sa-plantcare-tf"
}

resource "google_service_account" "github-sa" {
  account_id   = "github-sa"
  display_name = "Service Account for github"
}

resource "google_project_iam_member" "container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.github-sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github-sa.email}"
}

resource "google_project_iam_member" "cluster_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.github-sa.email}"
}

resource "google_project_iam_member" "artifactregistry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github-sa.email}"
}

resource "google_service_account_iam_member" "github_sa_impersonates_tf-sa" {
  service_account_id = data.google_service_account.terraform-sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.github-sa.email}"
}
