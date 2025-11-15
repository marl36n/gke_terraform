variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-southeast1-a"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "digital-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "gke-subnet"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.10.0.0/16"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "gke-cluster"
}

variable "location" {
  description = "Location for GKE cluster (region or zone). Use region for regional cluster"
  type        = string
  default     = "asia-southeast1"
}

variable "initial_node_count" {
  description = "Initial node count for default node pool"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}