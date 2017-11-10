resource "null_resource" "etcd_secrets" {
  count = "${length(var.etcd_member_domains)}"
  connection {
    type    = "ssh"
    host    = "${element(var.etcd_member_domains, count.index)}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = "${file(var.etcd_ca_cert_path)}"
    destination = "$HOME/etcd_ca.crt"
  }

  provisioner "file" {
    content     = "${file(var.etcd_server_cert_path)}"
    destination = "$HOME/etcd_server.crt"
  }

  provisioner "file" {
    content     = "${file(var.etcd_server_key_path)}"
    destination = "$HOME/etcd_server.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd",
      "sudo mv /home/core/etcd_ca.crt /etc/ssl/etcd/ca.crt",
      "sudo mv /home/core/etcd_server.crt /etc/ssl/etcd/server.crt",
      "sudo mv /home/core/etcd_server.key /etc/ssl/etcd/server.key",
      "sudo chown etcd:etcd /etc/ssl/etcd/*",
      "sudo chmod 0400 /etc/ssl/etcd/*",
    ]
  }
}