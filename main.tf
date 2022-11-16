provider "google" {
  credentials = file("ttec-test.json")
  project = "noc-test-project"
  region  = "us-central1"
  zone    = "us-central1-a"
}


resource "google_cloud_run_service" "default" {
  name     = "demo"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/noc-test-project/hello-dotnet"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
