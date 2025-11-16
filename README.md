# gke_terraform
this repo holds gke cluster and cloud build ci/cd pipeline to deploy sample node js application


===============================
# GKE CI/CD Deployment Guide

This guide explains how to set up a complete Google Kubernetes Engine (GKE) deployment pipeline using:

- Terraform for infrastructure (VPC, Subnets, NAT, GKE, IAM)
- Cloud Build for CI/CD
- Artifact Registry for container images
- Kubernetes manifests for workload deployment
- Workload Identity for secure authentication

---

## Overview

The final architecture includes:

- A **custom VPC** with subnet and secondary ranges for Pods and Services
- **Cloud Router + Cloud NAT** for private nodes to reach the internet
- A **GKE cluster** with Workload Identity enabled
- An **Artifact Registry** repository to store Docker images
- A **Cloud Build** CI/CD pipeline that:
  - Builds the Node.js application
  - Builds and pushes a Docker image
  - Connects to the GKE cluster
  - Applies Kubernetes deployment manifests
- A **secure Kubernetes Service Account** mapped to a **GCP Service Account** via Workload Identity

---

# 1. Create Infrastructure With Terraform

### 1.1 Clone Terraform infrastructure
```bash
git clone <infra-repo>
cd terraform
```

### 1.2 Initialize Terraform
```bash
terraform init
```

### 1.3 Apply Terraform
```bash
terraform apply
```

Terraform will provision:

- VPC and subnets
- Secondary IP ranges for pods & services
- Firewall rules
- Cloud Router & Cloud NAT
- GKE cluster with Workload Identity enabled
- IAM roles for GKE and Cloud Build

After apply completes, Terraform outputs:

- `cluster_name`
- `cluster_zone`
- `project_id`

---

# 2. Configure Workload Identity

A Kubernetes Service Account (KSA) maps to a Google Service Account (GSA).

### 2.1 Create Kubernetes Service Account
```bash
kubectl create serviceaccount nodejs-sa
```

### 2.2 Annotate KSA to bind with GSA
Assuming GSA is:
```
gke-primary@PROJECT_ID.iam.gserviceaccount.com
```
Run:
```bash
kubectl annotate serviceaccount nodejs-sa \
  iam.gke.io/gcp-service-account=gke-primary@PROJECT_ID.iam.gserviceaccount.com
```

### 2.3 Grant necessary IAM roles to the GSA
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:gke-primary@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"
```

Add more roles depending on app needs.

---

# 3. Set Up Artifact Registry Repository

### Create Docker repository
```bash
gcloud artifacts repositories create node-app \
  --repository-format=docker \
  --location=asia-southeast1 \
  --description="Node.js app images"
```

---

# 4. Cloud Build CI/CD Setup

`cloudbuild.yaml` performs the following:

1. Build Docker image
2. Push image to Artifact Registry
3. Connect to GKE cluster
4. Deploy Kubernetes manifests

### 4.1 Give Cloud Build permission to deploy to GKE
```bash
PROJECT_ID=$(gcloud config get-value project)
CLOUD_BUILD_SA="$PROJECT_ID@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CLOUD_BUILD_SA" \
  --role="roles/container.developer"
```

Also allow access to Artifact Registry:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CLOUD_BUILD_SA" \
  --role="roles/artifactregistry.writer"
```

---

# 5. Node.js Project Structure

Example structure:
```
/node_project
  ├── Dockerfile
  ├── index.js
  ├── package.json

```

---

# 6. Dockerfile
A simple Node.js image:
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

---

# 7. Kubernetes Deployment Manifest
Includes workload identity, resource limits, HPA, probes, and service.

(Stored in `kubernetes_yaml directory`)

The manifest contains:

- Deployment
- LoadBalancer service
- Horizontal Pod Autoscaler (HPA)
- Readiness & liveness probes
- Workload Identity service account

---

# 8. Cloud Build Pipeline
Run build & deploy:
```bash
gcloud builds submit --config cloudbuild.yaml .
```

Cloud Build will:

1. Build & push Docker image → Artifact Registry
2. Connect to GKE via `gcloud container clusters get-credentials`
3. Apply Kubernetes YAML using `kubectl apply`

---

# 9. Verify Deployment

### 9.1 Get service external IP
```bash
kubectl get svc nodejs-service
```

Visit:
```
http://EXTERNAL_IP
```

### 9.2 Check pods
```bash
kubectl get pods
```

### 9.3 View logs
```bash
kubectl logs -l app=nodejs-app
```

---

# 10. Conclusion
This project now have:

- A production-ready GKE cluster (private nodes + NAT + secure networking)
- Workload Identity-based secure access
- Cloud Build-powered CI/CD pipeline
- Scalable Node.js Kubernetes deployment



