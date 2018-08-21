# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

variable "hcloud_token" {
  default = "xxx"
}

variable "prefix" {
  default = "test"
}

variable "rancher_version" {
  default = "latest"
}

variable "count_agent_all_nodes" {
  default = "3"
}

variable "count_agent_etcd_nodes" {
  default = "0"
}

variable "count_agent_controlplane_nodes" {
  default = "0"
}

variable "count_agent_worker_nodes" {
  default = "0"
}

variable "admin_password" {
  default = "admin"
}

variable "cluster_name" {
  default = "quickstart"
}

variable "region" {
  default = "hel1"
}

variable "size" {
  default = "cx21"
}

variable "docker_version_server" {
  default = "17.03"
}

variable "docker_version_agent" {
  default = "17.03"
}

variable "ssh_keys" {
  default = []
}

resource "hcloud_server" "rancherserver" {
  count       = "1"
  image       = "ubuntu-18.04"
  name        = "${var.prefix}-rancherserver"
  location    = "${var.region}"
  server_type = "${var.size}"
  user_data   = "${data.template_file.userdata_server.rendered}"
  ssh_keys    = "${var.ssh_keys}"
}

resource "hcloud_server" "rancheragent-all" {
  count       = "${var.count_agent_all_nodes}"
  image       = "ubuntu-18.04"
  name        = "${var.prefix}-rancheragent-${count.index}-all"
  location    = "${var.region}"
  server_type = "${var.size}"
  user_data   = "${data.template_file.userdata_agent.rendered}"
  ssh_keys    = "${var.ssh_keys}"
}

resource "hcloud_server" "rancheragent-etcd" {
  count       = "${var.count_agent_etcd_nodes}"
  image       = "ubuntu-18.04"
  name        = "${var.prefix}-rancheragent-${count.index}-etcd"
  location    = "${var.region}"
  server_type = "${var.size}"
  user_data   = "${data.template_file.userdata_agent.rendered}"
  ssh_keys    = "${var.ssh_keys}"
}

resource "hcloud_server" "rancheragent-controlplane" {
  count       = "${var.count_agent_controlplane_nodes}"
  image       = "ubuntu-18.04"
  name        = "${var.prefix}-rancheragent-${count.index}-controlplane"
  location    = "${var.region}"
  server_type = "${var.size}"
  user_data   = "${data.template_file.userdata_agent.rendered}"
  ssh_keys    = "${var.ssh_keys}"
}

resource "hcloud_server" "rancheragent-worker" {
  count       = "${var.count_agent_worker_nodes}"
  image       = "ubuntu-18.04"
  name        = "${var.prefix}-rancheragent-${count.index}-worker"
  location    = "${var.region}"
  server_type = "${var.size}"
  user_data   = "${data.template_file.userdata_agent.rendered}"
  ssh_keys    = "${var.ssh_keys}"
}

data "template_file" "userdata_server" {
  template = "${file("files/userdata_server")}"

  vars {
    admin_password        = "${var.admin_password}"
    cluster_name          = "${var.cluster_name}"
    docker_version_server = "${var.docker_version_server}"
    rancher_version       = "${var.rancher_version}"
  }
}

data "template_file" "userdata_agent" {
  template = "${file("files/userdata_agent")}"

  vars {
    admin_password       = "${var.admin_password}"
    cluster_name         = "${var.cluster_name}"
    docker_version_agent = "${var.docker_version_agent}"
    rancher_version      = "${var.rancher_version}"
    server_address       = "${hcloud_server.rancherserver.ipv4_address}"
  }
}

output "rancher-url" {
  value = ["https://${hcloud_server.rancherserver.ipv4_address}"]
}
