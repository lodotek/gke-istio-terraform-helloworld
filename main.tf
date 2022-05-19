locals {
  cluster_type = "simple-zonal-private"
}
locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
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
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                    = "21.0.0"
  enable_private_endpoint    = false
  enable_private_nodes       = true
  horizontal_pod_autoscaling = true
  http_load_balancing        = false
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  istio                      = true
  master_ipv4_cidr_block     = "10.0.0.0/28"
  name                       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  network                    = var.network
  project_id                 = var.project_id
  region                     = var.region
  remove_default_node_pool   = true
  service_account            = var.compute_engine_service_account
  subnetwork                 = var.subnetwork
  zones                      = var.zones
  kubernetes_version         = "latest"


  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    },
    {
      cidr_block   = "${local.ifconfig_co_json.ip}/32"
      display_name = "Your IP"
    },
  ]

  node_pools = [
    {
      name               = "custom-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "us-central1-b,us-central1-c"
      min_count          = 1
      max_count          = 10
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "terraform@crucial-utility-349720.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    custom-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    custom-node-pool = {
      custom-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    custom-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    custom-node-pool = [
      {
        key    = "custom-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    custom-node-pool = [
      "custom-node-pool",
    ]
  }
}

resource "kubernetes_namespace" "myapp" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      istio-injection = "enabled"
    }

    name = "myapp"
  }
}

# Wait for Istio
resource "time_sleep" "wait_istio" {
  depends_on      = [module.gke, kubernetes_namespace.myapp]
  create_duration = "30s"
}


resource "null_resource" "local_k8s_context" {
  depends_on = [time_sleep.wait_istio]
  provisioner "local-exec" {
    # Update your local gcloud and kubectl credentials for the newly created cluster
    command = "for i in 1 2 3 4 5; do gcloud container clusters get-credentials ${module.gke.name} --project=${var.project_id} --region=${var.region} && break || sleep 60; done"
  }
}

resource "null_resource" "install_helloworld" {
  depends_on = [null_resource.local_k8s_context]
  provisioner "local-exec" {
    # Update your local gcloud and kubectl credentials for the newly created cluster
    command = "./scripts/install-helloworld.sh"
  }
}

data "kubernetes_service" "istio_ingress" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = "istio-system"
  }

  depends_on = [null_resource.install_helloworld]
}
output "your_ip_addr" {
  value = local.ifconfig_co_json.ip
}

output "ingress_ip" {
  value = data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.ip
}

output "app_url" {
  value = "http://${data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.ip}/hello"
}
