terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  # "remote-like" shared folder, ignored by git (*.tfstate*)
  backend "local" {
    path = "../../state/dev.tfstate"
  }
}

provider "docker" {}

variable "env_name" { type = string }
variable "image" { type = string }
variable "external_port" { type = number }

# the module was missing, so module.webapp.app_url pointed to nothing
module "webapp" {
  source        = "../../modules/webapp"
  env_name      = var.env_name
  image         = var.image
  external_port = var.external_port
}

output "app_url" {
  value = module.webapp.app_url
}