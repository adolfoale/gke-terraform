project_id          = "optical-caldron-421816"
cluster_name_suffix = "gke-test"
region              = "us-central1"
zones = [
  "us-central1-a",
  "us-central1-b",
  "us-central1-f"
]
network                        = "default"
subnetwork                     = "default"
ip_range_pods                  = ""
ip_range_services              = ""
compute_engine_service_account = "791582853027-compute@developer.gserviceaccount.com"
http_load_balancing            = false
network_policy                 = false
horizontal_pod_autoscaling     = true
filestore_csi_driver           = false
deletion_protection            = false