/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "simple-regional-private"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork
  project = var.project_id
  region  = var.region
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 30.0"

  project_id                 = var.project_id
  name                       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                   = true
  region                     = var.region
  zones                      = var.zones
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  http_load_balancing        = var.http_load_balancing
  network_policy             = var.network_policy
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  filestore_csi_driver       = var.filestore_csi_driver
  deletion_protection        = var.deletion_protection
  create_service_account     = false
  service_account            = var.compute_engine_service_account
  enable_private_endpoint    = true
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "172.16.0.0/28"
  default_max_pods_per_node  = 8
  remove_default_node_pool   = true

  node_pools = [
    {
      name              = "pool-01"
      machine_type      = "e2-micro"
      node_locations    = "us-central1-a,us-central1-b,us-central1-c"
      min_count         = 1
      max_count         = 1
      local_ssd_count   = 0
      spot              = false
      disk_size_gb      = 20
      disk_type         = "pd-standard"
      image_type        = "COS_CONTAINERD"
      enable_gcfs       = false
      enable_gvnic      = false
      logging_variant   = "DEFAULT"
      auto_repair       = true
      auto_upgrade      = true
      service_account   = var.compute_engine_service_account
      preemptible       = false
      max_pods_per_node = 8
    },
  ]

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    },
  ]
}
