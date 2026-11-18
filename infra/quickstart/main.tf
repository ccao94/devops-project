terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# talks to the local Docker Desktop daemon
provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

resource "docker_container" "web" {
  name = "tf-web"
  # reference to the image, so terraform creates it first
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8082
  }
}