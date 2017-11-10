variable "matchbox_http_endpoint" {
  type        = "string"
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "matchbox_rpc_endpoint" {
  type        = "string"
  description = "Matchbox gRPC API endpoint, without the protocol (e.g. matchbox.example.com:8081)"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to set as an authorized_key on machines"
}

variable "etcd_member_names" {
  type = "list"

  description = <<EOF
Ordered list of worker names.

Example: `["node2", "node3"]`
EOF
}

variable "etcd_member_domains" {
  type = "list"

  description = <<EOF
Ordered list of controller domain names.

Example: `["node2.example.com", "node3.example.com"]`
EOF
}

variable "etcd_member_macs" {
  type = "list"

  description = <<EOF
Ordered list of controller MAC addresses for matching machines.

Example: `["52:54:00:a1:9c:ae", "52:54:00:a1:9c:ab"]`
EOF
}

variable "tls_enabled" {
  type    = "string"
  default = ""

  description = <<EOF
If set to true we will configure peer_auto_tls and you must provide the CA Cert Server Cert and the Server Key paths
EOF
}

variable "etcd_ca_cert_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
The path of the file containing the CA certificate for TLS communication with etcd.
EOF
}

variable "etcd_server_cert_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
The path of the file containing the server certificate for TLS communication with etcd.
EOF
}

variable "etcd_server_key_path" {
  type    = "string"
  default = "/dev/null"

  description = <<EOF
The path of the file containing the server key for TLS communication with etcd.
EOF
}

# optional

variable "install_disk" {
  type        = "string"
  default     = "/dev/sda"
  description = "Disk device to which the install profiles should install Container Linux (e.g. /dev/sda)"
}

variable "container_linux_oem" {
  type        = "string"
  default     = ""
  description = "Specify an OEM image id to use as base for the installation (e.g. ami, vmware_raw, xen) or leave blank for the default image"
}
