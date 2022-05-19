# Install helloworld, VirtualService, and Gateway
resource "null_resource" "helloworld" {
  depends_on = [null_resource.local_k8s_context]
  provisioner "local-exec" {
    command = "./scripts/install-helloworld.sh"
  }
}
