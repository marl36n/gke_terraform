resource "google_service_account" "gke_primary" {
  account_id = "gke-primary"
  display_name = "GKE service account for terraform-managed cluster"
}


# Grant common roles needed to manage and run GKE. Review and tighten for least privilege.
resource "google_project_iam_member" "sa_container_admin" {
  project = var.project_id
  role = "roles/container.admin"
  member = "serviceAccount:${google_service_account.gke_primary.email}"
}


resource "google_project_iam_member" "sa_service_account_user" {
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.gke_primary.email}"
}


resource "google_project_iam_member" "sa_network_admin" {
  project = var.project_id
  role = "roles/compute.networkAdmin"
  member = "serviceAccount:${google_service_account.gke_primary.email}"
}


# Optional: allow the GKE nodes' SA to pull images from project's Artifact Registry / Container Registry
resource "google_project_iam_member" "node_service_account_artifact" {
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke_primary.email}"
}