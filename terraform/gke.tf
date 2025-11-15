# Create the GKE cluster. This example creates a zonal cluster. For regional, set location accordingly and `location = var.region`.
resource "google_container_cluster" "primary" {
  # Enable private nodes
  private_cluster_config {
    enable_private_nodes       = true
    enable_private_endpoint    = false
    master_ipv4_cidr_block    = "172.16.0.0/28"
  }

  name     = var.cluster_name
  location = var.location

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "svc-range"
  }

  enable_shielded_nodes = true


  lifecycle {
    ignore_changes = [master_auth]
  }
}

# Secondary ranges must exist for IP allocation. Create them on the subnet.
resource "google_compute_subnetwork_iam_member" "allow_network_user" {
  subnetwork = google_compute_subnetwork.subnet.name
  region     = google_compute_subnetwork.subnet.region
  project    = var.project_id
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.gke_primary.email}"
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "primary-pool"
  location = var.location
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type   = var.machine_type
    oauth_scopes   = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    service_account = google_service_account.gke_primary.email
  }

  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}
