locals {
  content_ansible_group_vars = templatefile("${path.module}/files/templates/all.yml.tftpl", {
    k3s_version                  = var.k3s_version,
    ansible_user                 = var.ansible_user,
    ansible_ssh_private_key_file = var.ansible_ssh_private_key_file,
    systemd_dir                  = var.systemd_dir
    extra_server_args            = join(" ", ["--tls-san ${var.fqdn}", "--secrets-encryption", var.extra_server_args])
    ansible_ssh_common_args      = var.ansible_ssh_common_args
    extra_agent_args             = var.extra_agent_args,
  })
  content_ansible_hosts_init = templatefile("${path.module}/files/templates/hosts.ini.tftpl", { fqdn = var.fqdn })
  short_hostname = split(".", var.fqdn)[0]
  kubeconfig = replace(
    replace(base64decode(data.external.kubectl.result.output), "default", local.short_hostname),
    "127.0.0.1",
    var.fqdn
  )
}

resource "null_resource" "ansible_ping" {
  triggers = {
    filename    = "files/${var.node}/hosts.ini"
    filecontent = join("\n",[local.content_ansible_hosts_init, local.content_ansible_group_vars])
  }

  provisioner "local-exec" {
    command = "ansible -i files/${var.node}/hosts.ini -m ping all"
    environment = {
      ANSIBLE_CONFIG = "${path.module}/files/ansible.cfg"
    }
  }
}

resource "null_resource" "ansible_install_k3s" {
  depends_on = [null_resource.ansible_ping]
  triggers = {
    filename    = "files/${var.node}/group_vars/all.yml"
    filecontent = join("\n",[local.content_ansible_hosts_init, local.content_ansible_group_vars])
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/files/k3s-ansible/site.yml -i files/${var.node}/hosts.ini"
    environment = {
      ANSIBLE_CONFIG = "${path.module}/files/ansible.cfg"
    }
  }
}

output "command" {
  value = "ansible-playbook ${path.module}/files/k3s-ansible/site.yml -i files/${var.node}/hosts.ini --check"
}

resource "local_file" "ansible_hosts_init" {
  content              = local.content_ansible_hosts_init
  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "files/${var.node}/hosts.ini"
}

resource "local_file" "ansible_group_vars" {
  content              = local.content_ansible_group_vars
  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "files/${var.node}/group_vars/all.yml"
}


data "external" "kubectl" {
  depends_on = [null_resource.ansible_install_k3s]
  program = ["bash", "${path.module}/files/copy_config.sh"]

  query = {
    ssh_key = var.ansible_ssh_private_key_file
    ssh_user = var.ansible_user
    fqdn = var.fqdn
  }
}

output "kubeconfig" {
  value = local.kubeconfig
  sensitive = true
}