variable "node" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "k3s_version" {
  type    = string
  default = "v1.21.2+k3s1"
}

variable "ansible_user" {
  type    = string
  default = "ansible"
}

variable "ansible_ssh_private_key_file" {
  type    = string
  default = "~/.ssh/id_ed25519"
}

variable "systemd_dir" {
  type    = string
  default = "/etc/systemd/system"
}

variable "extra_server_args" {
  type    = string
  default = "--disable traefik"
}

variable "extra_agent_args" {
  type    = string
  default = ""
}

variable "ansible_ssh_common_args" {
  type    = string
  default = ""
}
