provider "kubernetes" {}

provider "helm" {}


resource "kubernetes_pod" "mqtt" {
    metadata {
        name = "mqtt"
        labels = {
            App = "mqtt"
        }
    }

    spec {
        container {
            image = "eclipse-mosquitto:1.6"
            name  = "mqtt"
        
            port {
                container_port = 1883
            }

            port {
                container_port = 9001
            }
        }
    }
}

resource "kubernetes_service" "mqtt" {
  metadata {
      name = "mqtt"
  }
  spec {
      selector = {
          App = kubernetes_pod.mqtt.metadata.0.labels.App
      }
      port {
          name        = "test-1"
          port        = 1883
          target_port = 1883
      }

      port {
          name        = "test-2"
          port        = 9001
          target_port = 9001
      }

      type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "mqtt" {
    metadata {
        name = "mqtt"
    }

    spec {
        rule {
            http {
                path {
                    backend {
                        service_name = kubernetes_service.mqtt.metadata[0].name
                        service_port = "1883"
                    }
                    path = "/"
                }
            }
        }
    }
}

module "pihole" {
  source = "./modules/pihole"
}

//module "helm" {
//  source = "./modules/helm"
//}
