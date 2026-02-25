variable "token" {
  description = "Yandex Cloud OAuth token (yc iam create-token)"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-b"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key to install on VMs"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
