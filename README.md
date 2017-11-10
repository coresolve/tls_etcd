# etcd3 with peer auto tls and provided certs.

## Constraints

* For each member use a provided certificate that has only the CN and SAN set for that hostname.
* Configure PEER_AUTO_TLS for peer encryption
* Configure the cluster to use MTLS and provide a ca cert that will be used to verify clients.

## Requirements

* Matchbox v0.6+ [installation](../../../Documentation/deployment.md) with gRPC API enabled
* Matchbox provider credentials `matchbox/client.crt`, `matchbox/client.key`, and `matchbox/ca.crt`
* Etcd tls assets `etcd/server.crt` `etcd/server.key` `etcd/ca.key`
* Etcd tls assets `etcd/client.crt` and `etcd/client.key`
* The server cert must have a SAN IP of 127.0.0.1 and a san for every hostname in the cluster.
* PXE [network boot](../../../Documentation/network-setup.md) environment
* Terraform v0.9+ and [terraform-provider-matchbox](https://github.com/coreos/terraform-provider-matchbox) installed locally on your system
* 3 machines with known DNS names and MAC addresses

If you prefer to provision QEMU/KVM VMs on your local Linux machine, set up the matchbox [development environment](../../../Documentation/getting-started-rkt.md).

```sh
sudo ./scripts/devnet create
```

## Usage

Clone the [matchbox](https://github.com/coreos/matchbox) project and take a look at the cluster examples.

```sh
$ git clone https://github.com/coreos/matchbox.git
$ cd matchbox/examples/terraform/etcd3-install
```

Copy the `terraform.tfvars.example` file to `terraform.tfvars`. Ensure `provider.tf` references your matchbox credentials.

```hcl
matchbox_http_endpoint      = "http://matchbox.example.com:8080"
matchbox_rpc_endpoint       = "matchbox.example.com:8081"
matchbox_ca_cert_file       = "./matchbox/ca.crt"
matchbox_client_cert_file   = "./matchbox/client.crt"
matchbox_client_key_file    = "./matchbox/client.key"
ssh_authorized_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant_rsa"
etcd_member_names           = ["node001", "node002", "node003"]
etcd_member_domains         = ["node001.metal.k8s.work", "node002.metal.k8s.work", "node003.metal.k8s.work"]
etcd_member_macs            = ["08:00:27:00:00:01", "08:00:27:00:00:02", "08:00:27:00:00:03"]
etcd_server_cert_path       = ["./etcd/node001.metal.k8s.work.crt", "./etcd/node002.metal.k8s.work.crt", "./etcd/node003.metal.k8s.work.crt"]
etcd_server_key_path        = ["./etcd/node001.metal.k8s.work.key", "./etcd/node002.metal.k8s.work.key", "./etcd/node003.metal.k8s.work.key"]
etcd_ca_cert_path           = "./etcd/ca.crt"
```

Configs in `etcd3-install` configure the matchbox provider, define profiles (e.g. `cached-container-linux-install`, `etcd3`), and define 3 groups which match machines by MAC address to a profile. These resources declare that the machines should PXE boot, install Container Linux to disk, and provision themselves into peers in a 3-node etcd3 cluster.

Note: The `cached-container-linux-install` profile will PXE boot and install Container Linux from matchbox [assets](https://github.com/coreos/matchbox/blob/master/Documentation/api.md#assets). If you have not populated the assets cache, use the `container-linux-install` profile to use public images (slower).

### Optional

You may set certain optional variables to override defaults.

```hcl
# install_disk = "/dev/sda"
# container_linux_oem = ""
```

## Apply

Fetch the [profiles](../README.md#modules) Terraform [module](https://www.terraform.io/docs/modules/index.html) which let's you use common machine profiles maintained in the matchbox repo (like `etcd3`).

```sh
$ terraform init
```

Plan and apply to create the resoures on Matchbox.

```sh
$ terraform plan
Plan: 10 to add, 0 to change, 0 to destroy.
$ terraform apply
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
```

## Machines

Power on each machine (with PXE boot device on next boot). Machines should network boot, install Container Linux to disk, reboot, and provision themselves as a 3-node etcd3 cluster. 

```sh
$ ipmitool -H node1.example.com -U USER -P PASS chassis bootdev pxe
$ ipmitool -H node1.example.com -U USER -P PASS power on
```

For local QEMU/KVM development, create the QEMU/KVM VMs.

```sh
$ sudo ./scripts/libvirt create
$ sudo ./scripts/libvirt [start|reboot|shutdown|poweroff|destroy]
```

## Verify

Verify each node is running etcd3 (i.e. etcd-member.service).

```sh
$ ssh core@node1.example.com
$ systemctl status etcd-member
```

Verify that etcd3 peers are healthy and communicating.

```sh
$ ETCDCTL_API=3 etcdctl --cacert=./etcd/ca.crt --cert=./etcd/client.crt --key=./etcd/client.key --endpoints=https://node001.metal.k8s.work:2379,https://node002.metal.k8s.work:2379,https://node003.metal.k8s.work:2379 member list
76f6fd44a6265301, started, node003, https://node003.metal.k8s.work:2380, https://node003.metal.k8s.work:2379
8fbc6b3a15e12cb6, started, node001, https://node001.metal.k8s.work:2380, https://node001.metal.k8s.work:2379
9d963fb82799c5e4, started, node002, https://node002.metal.k8s.work:2380, https://node002.metal.k8s.work:2379
$ etcdctl set /message hello
$ etcdctl get /message
```

## Going Further

Learn more about [matchbox](../../../Documentation/matchbox.md) or explore the other [example](../) clusters.
