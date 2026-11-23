terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
  # path given at init time, one state file per PR
  backend "local" {}
}

variable "pr_number" { type = string }
variable "image" { type = string }

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-devops-lab"
}

resource "kubernetes_namespace" "preview" {
  metadata {
    name = "pr-${var.pr_number}"
    labels = {
      purpose = "preview"
      pr      = var.pr_number
      # cost control: who owns it and when it can be deleted
      owner   = "cao"
      expires = "2026-11-30"
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.preview.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "myapp" }
    }
    template {
      metadata {
        labels = { app = "myapp" }
      }
      spec {
        # run as the non-root user created in our Dockerfile
        security_context {
          run_as_non_root = true
          run_as_user     = 10001
        }
        container {
          name              = "myapp"
          image             = var.image
          image_pull_policy = "Always"
          port {
            # spring boot listens on 8080, not 3000
            container_port = 8080
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "500m", memory = "256Mi" }
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
          }
          # spring boot (tomcat) needs to write in /tmp
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.preview.metadata[0].name
  }
  spec {
    selector = { app = "myapp" }
    port {
      port        = 80
      target_port = 8080
    }
  }
}