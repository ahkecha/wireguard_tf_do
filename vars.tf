variable "digitalocean_token" {
	# default = "ZXhhbXBsZV9wcml2YXRlX2tleV8xMjM0NTY3ODkwMTIzNDU2NzgK"
}
variable "private_key" {
	type = string
	# default = "ZXhhbXBsZV9wcml2YXRlX2tleV8xMjM0NTY3ODkwMTIzNDU2NzgK"// Insert Private Key here
}

variable "public_key" {
	type = string
	# default = "ZXhhbXBsZV9wcml2YXRlX2tleV8xMjM0NTY3ODkwMTIzNDU2NzgK" // Insert PubKey here
}

variable "wireguard_ip_addr" {
	type = string
	# default = "10.66.66.1/24,fd42:42:42::1/64"
}

variable "allowed_addr" {
	type = string
	# default = "10.66.66.2/32,fd42:42:42::2/128"
}

variable "preshared_key" {
	type = string
	description = "Generate one with 'openssl rand -base64 32' or use 'wg genpsk'"
}

locals {
  description = "Wireguard port"
  wg_port = "${random_integer.wireguard_port.result}"
}

resource "random_integer" "wireguard_port" {
  min = 30000
  max = 59357
}


data "template_file" "wg_interface" {
  template = file("${path.module}/templates/wg.tpl")

  vars = {
	wireguard_ip_addr = "${var.wireguard_ip_addr}"
	allowed_addr      = "${var.allowed_addr}"
    port              = "${local.wg_port}"
    privatekey        = "${var.private_key}"
	public_key        = "${var.public_key}"
	preshared_key     = "${var.preshared_key}"
  }
}

