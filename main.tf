terraform {
  required_version = ">= 1.0.0" # Adjusted to a valid Terraform version

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.1.0"
    }
    google_beta = { # Quoted to fix HCL syntax error
      source  = "hashicorp/google-beta"
      version = "~> 4.2.0"
    }
  }
}

provider "google" {
  project     = "watchful-idea-505906-u3"
  region      = "us-central-1"
  credentials = var.gcp_credentials
}
resource "google_pubsub_lite_topic" "example" {
  name = "example-topic"
  project = data.google_project.project.number
  partition_config {
    count = 1
    capacity {
      publish_mib_per_sec = 4
      subscribe_mib_per_sec = 8
    }
  }

  retention_config {
    per_partition_bytes = 32212254720
  }
}

resource "google_pubsub_lite_subscription" "example" {
  name  = "example-subscription"
  topic = google_pubsub_lite_topic.example.name
  delivery_config {
    delivery_requirement = "DELIVER_AFTER_STORED"
  }
}

data "google_project" "project" {
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
