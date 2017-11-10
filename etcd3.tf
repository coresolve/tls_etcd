// Create popular profiles (convenience module)
module "profiles" {
  source                  = "./profiles"
  matchbox_http_endpoint  = "${var.matchbox_http_endpoint}"
  container_linux_version = "1520.8.0"
  container_linux_channel = "stable"
  install_disk            = "${var.install_disk}"
  container_linux_oem     = "${var.container_linux_oem}"
}

// Install Container Linux to disk before provisioning
resource "matchbox_group" "coreos_install" {
  count   = "${length(var.etcd_member_domains)}"
  name    = "${format("coreos-install-%s", element(var.etcd_member_names, count.index))}"
  profile = "${module.profiles.cached-container-linux-install}"

  selector {
    mac = "${element(var.etcd_member_macs, count.index)}"
  }

  metadata {
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

data "template_file" "etcd_initial_cluster" {
  count    = "${length(var.etcd_member_domains)}"
  template = "https://${var.etcd_member_domains[count.index]}:2380"
}

resource "matchbox_group" "etcd_member" {
  count   = "${length(var.etcd_member_domains)}"
  name    = "${element(var.etcd_member_domains, count.index)}"
  profile = "${module.profiles.etcd3}"

  selector {
    mac = "${element(var.etcd_member_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.etcd_member_domains, count.index)}"
    etcd_name            = "${element(var.etcd_member_names, count.index)}"
    etcd_initial_cluster = "${join(",", data.template_file.etcd_initial_cluster.*.rendered)}"
    ssh_authorized_key   = "${var.ssh_authorized_key}"
  }
}
