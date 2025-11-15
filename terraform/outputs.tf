output "cluster_name" {
  value = google_container_cluster.primary.name
}


output "endpoint" {
  value = google_container_cluster.primary.endpoint
}


output "kubeconfig_client_certificate" {
  value = google_container_cluster.primary.master_auth[0].client_certificate
  sensitive = true
}


output "gke_service_account_email" {
  value = google_service_account.gke_primary.email
}