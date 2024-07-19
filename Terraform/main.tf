provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud SQL database instance
resource "google_sql_database_instance" "db_instance" {
  name             = "my-database-instance"
  database_version = "POSTGRES_13"
  settings {
    tier = "db-f1-micro"
  }
}

# Cloud SQL database within the instance
resource "google_sql_database" "db" {
  name     = var.database_name
  instance = google_sql_database_instance.db_instance.name
}

# Cloud Run service
resource "google_cloud_run_service" "service" {
  name     = "my-cloud-run-service"
  location = var.region
  template {
    spec {
      containers {
        image = var.container_image
      }
    }
  }
}

# global IP address for LB
resource "google_compute_global_address" "default" {
  name = "global-address"
}

# URL map to route traffic to Cloud Run service
resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_cloud_run_service.service.status[0].url
}

# HTTP proxy to route traffic
resource "google_compute_target_http_proxy" "default" {
  name   = "http-proxy"
  url_map = google_compute_url_map.default.id
}

# global forwarding rule to route traffic to the HTTP proxy
resource "google_compute_global_forwarding_rule" "default" {
  name        = "global-forwarding-rule"
  target      = google_compute_target_http_proxy.default.id
  port_range  = "80"
  ip_address  = google_compute_global_address.default.address
}