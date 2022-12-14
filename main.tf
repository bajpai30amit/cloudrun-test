terraform {
  required_version = ">= 1.1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.1.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.2.0"
    }
  }
}

provider "google" {
  project     = "noc-test-project"
  region      = "us-central-1"
  credentials = file("66-test.json")
}

resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
