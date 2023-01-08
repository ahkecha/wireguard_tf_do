terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.25.2"
    }
  }
}

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

locals {
  ssh_port = "${random_integer.ssh_port.result}"
}

resource "random_integer" "ssh_port" {
  min = 49152
  max = 65535
}

resource "tls_private_key" "SSH" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "default" {
  name       = "Default"
  // Generate a new SSH-Key, ssh-keygen
  public_key = tls_private_key.SSH.public_key_openssh
}

resource "digitalocean_droplet" "vps" {
  image = "debian-11-x64"
  name = "debian-Wireguard-VPN"
  region = "lon1"
  size = "s-1vcpu-1gb"
  monitoring = true
  ipv6 = false
  ssh_keys = [
    "${digitalocean_ssh_key.default.fingerprint}"
  ]

  connection {
	host = "${digitalocean_droplet.vps.ipv4_address}"
    user = "root"
    type = "ssh"
    private_key =  tls_private_key.SSH.private_key_openssh
    timeout = "2m"
  }
  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "add-apt-repository -y ppa:wireguard/wireguard",
      "apt-get install -y wireguard"
    ]
  }

  provisioner "file" {
    content = "${data.template_file.wg_interface.rendered}"
    destination = "/etc/wireguard/wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable wg-quick@wg0",
      "systemctl start wg-quick@wg0",
    ]
  }
  provisioner "local-exec" {
	command =<<EOF
		sed -i "s/^#Port .*/Port ${local.ssh_port}/" /etc/ssh/sshd_config
		systemctl restart ssh
		adduser --disabled-password --gecos "" w1r3
		mkdir -p /home/w1r3/.ssh
		echo "${var.public_key}" >> /home/w1r3/.ssh/authorized_keys
		chown -R w1r3:w1r3 /home/w1r3/.ssh
		adduser w1r3 sudo
	EOF
  }
}
