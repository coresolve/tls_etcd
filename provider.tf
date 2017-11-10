// Configure the matchbox provider
provider "matchbox" {
  endpoint    = "${var.matchbox_rpc_endpoint}"
  client_cert = "${file(var.matchbox_client_cert_path)}"
  client_key  = "${file(var.matchbox_client_key_path)}"
  ca          = "${file(var.matchbox_ca_cert_path)}"
}
