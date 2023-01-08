# Wireguard Terraform

Quickly set-up wireguard vpn on DigitalOcean, why? because i got bored and tired of redoing the same steps everytime i want to set it up...

## Deploying

Edit `vars.auto.tfvars` accordingly

```conf
digitalocean_token = "PUT_YOUR_TOKEN_HERE"
private_key = "WIREGUARD_PRIVATE_KEY"
public_key = "WIREGUARD_PUBLIC_KEY"
preshared_key = "WIREGUARD_PRESHARED_KEY"
wireguard_ip_addr = "IPV4, IPV6range of private addresses to use for clients"
allowed_addr = "allowed ip addresses"
```

Run the following:

```bash
$ terraform init
```

```bash
$ terraform plan
```

Deploy it:
```bash
$ terraform deploy
```

---
