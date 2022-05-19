## Description

Deploys a Private GKE cluster with Istio and a helloworld deployment plumbed up to an Istio Ingress Gateway via an Istio VirtualService.
#### Specifications:
* Private cluster
    * default node pool removed
    * Control plane authorized networks enabled
    * Custom node pool
        * Autoscaling
    * Shielded nodes
* Istio service mesh
    * Default install profile via tf module flag
    * Ingress Gateway
    * Gateway
    * Virtual Service
    * Custom myapp namespace
      * myapp namespace has istio-injection enabled
* App deployed into custom `myapp` namespace

### Deployment instructions:
Then perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

Terraform will provide outputs containing the app URL.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.20.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.1.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.11.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster | 21.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [kubernetes_namespace.myapp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [null_resource.helloworld](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_helloworld](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.local_k8s_context](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_istio](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [http_http.my_public_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [kubernetes_service.istio_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name_suffix"></a> [cluster\_name\_suffix](#input\_cluster\_name\_suffix) | A suffix to append to the default cluster name | `string` | `""` | no |
| <a name="input_compute_engine_service_account"></a> [compute\_engine\_service\_account](#input\_compute\_engine\_service\_account) | Service account to associate to the nodes in the cluster | `any` | n/a | yes |
| <a name="input_ip_range_pods"></a> [ip\_range\_pods](#input\_ip\_range\_pods) | The secondary ip range to use for pods | `any` | n/a | yes |
| <a name="input_ip_range_services"></a> [ip\_range\_services](#input\_ip\_range\_services) | The secondary ip range to use for services | `any` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | The VPC network to host the cluster in | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to host the cluster in | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `any` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The subnetwork to host the cluster in | `any` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | The zone to host the cluster in (required if is a zonal cluster) | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | n/a |
| <a name="output_ingress_ip"></a> [ingress\_ip](#output\_ingress\_ip) | n/a |
| <a name="output_your_ip_addr"></a> [your\_ip\_addr](#output\_your\_ip\_addr) | n/a |
<!-- END_TF_DOCS -->
