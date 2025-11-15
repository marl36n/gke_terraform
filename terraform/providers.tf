provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "googlebeta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}