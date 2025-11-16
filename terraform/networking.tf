resource "google_compute_network" "vpc" {
  name = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description = "VPC for GKE cluster"
}


resource "google_compute_subnetwork" "subnet" {
  name = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region = var.region
  network = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.20.0.0/14"
  }

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = "10.24.0.0/20"
  }
}


# Allow k8s API reachability and node egress
resource "google_compute_firewall" "allow-internal" {
  name = "gke-allow-internal"
  network = google_compute_network.vpc.name


  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }


  source_ranges = ["10.0.0.0/8"]
}


resource "google_compute_firewall" "allow-ssh-rdp" {
  name = "gke-allow-ssh-rdp"
  network = google_compute_network.vpc.name


  allow {
    protocol = "tcp"
    ports = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Cloud Router for NAT
resource "google_compute_router" "nat_router" {
  name = "gke-nat-router"
  network = google_compute_network.vpc.self_link
  region = var.region
}


# Cloud NAT configuration
resource "google_compute_router_nat" "nat_config" {
  name = "gke-cloud-nat"
  router = google_compute_router.nat_router.name
  region = var.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"


  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}