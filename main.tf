# k3s_nodes module
module "k3s_nodes" {
  for_each = var.k3s_nodes
  source      = "./modules/k3s_nodes"
  node        = each.key
  fqdn        = lookup(each.value, "fqdn")
  k3s_version = lookup(each.value, "k3s_version", null)
}
