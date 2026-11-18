variable "env_name" { type = string }
variable "image" { type = string }
variable "external_port" { type = number }

output "app_url" {
  value = module.webapp.app_url
}