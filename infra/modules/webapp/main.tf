terraform {
  required_providers {
    # needed in the module too, otherwise terraform looks for hashicorp/docker
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "nginx" {
  name = var.image
  # dev and staging share the same image, so destroy must not delete it
  keep_locally = true
}

resource "docker_container" "web" {
  name  = "tf-web-${var.env_name}"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = var.external_port
  }
}