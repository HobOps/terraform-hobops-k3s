# k3s_nodes module
module "k3s_nodes" {
  for_each = var.k3s_nodes
  node     = each.key
  source   = "./modules/k3s_nodes"

  ansible_ssh_common_args      = lookup(each.value, "ansible_ssh_common_args", "")
  ansible_ssh_private_key_file = lookup(each.value, "ansible_ssh_private_key_file", "~/.ssh/id_ed25519")
  ansible_user                 = lookup(each.value, "ansible_user", "ansible")
  extra_agent_args             = lookup(each.value, "extra_agent_args", "")
  extra_server_args            = lookup(each.value, "extra_server_args", "--disable traefik")
  fqdn                         = lookup(each.value, "fqdn")
  k3s_version                  = lookup(each.value, "k3s_version", null)
  systemd_dir                  = lookup(each.value, "systemd_dir", "/etc/systemd/system")
}
