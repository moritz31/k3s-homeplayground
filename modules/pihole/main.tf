
resource "kubernetes_storage_class" "pihole" {
    metadata {
        name = "pihole"
    }

    storage_provisioner = "kubernetes.io/no-provisioner"
}

resource "kubernetes_persistent_volume" "pihole" {
  metadata {
      name = "pihole"
      labels = {
          directory = "etc"
      }
  }

  spec {
      capacity = {
          storage = "1Gi"
      }
      access_modes = ["ReadWriteOnce"]
      persistent_volume_reclaim_policy = "Delete"
      persistent_volume_source {
          local {
              path = "/pihole"
          }
      }
      storage_class_name = kubernetes_storage_class.pihole.metadata[0].name
      node_affinity {
          required {
              node_selector_term {
                  match_expressions {
                      key = "kubernetes.io/hostname"
                      operator = "In"
                      values = [ "raspberrypi" ]
                  }
              }
          }
      }
  }
}

resource "kubernetes_persistent_volume_claim" "pihole" {
    metadata {
        name = "pihole"
    }

    spec {
        storage_class_name = kubernetes_storage_class.pihole.metadata[0].name
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "1Gi"
            }
        }

        selector {
            match_labels = {
                directory = "etc"
            }
        }
    }
}

resource "kubernetes_persistent_volume" "dnsmasq" {
  metadata {
      name = "pihole-dnsmasq"
      labels = {
          directory = "dnsmasq.d"
      }
  }

  spec {
      capacity = {
          storage = "1Gi"
      }
      access_modes = ["ReadWriteOnce"]
      persistent_volume_reclaim_policy = "Delete"
      persistent_volume_source {
          local {
              path = "/dnsmasq.d"
          }
      }
      storage_class_name = kubernetes_storage_class.pihole.metadata[0].name
      node_affinity {
          required {
              node_selector_term {
                  match_expressions {
                      key = "kubernetes.io/hostname"
                      operator = "In"
                      values = [ "raspberrypi" ]
                  }
              }
          }
      }
  }
}

resource "kubernetes_persistent_volume_claim" "dnsmasq" {
    metadata {
        name = "pihole-dnsmasq"
    }

    spec {
        storage_class_name = kubernetes_storage_class.pihole.metadata[0].name
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "500Mi"
            }
        }

        selector {
            match_labels = {
                directory = "dnsmasq.d"
            }
        }
    }
}

resource "kubernetes_deployment" "pihole" {
  metadata {
      name = "pihole"
      labels = {
          app = "pihole"
      }
  }

  spec {
      replicas = "1"
      selector {
          match_labels = {
              app = "pihole"
          }
      }
      template {
          metadata {
              labels = {
                  app = "pihole"
                  name = "pihole"
              }
          }

          spec {
              container {
                  name = "pihole"
                  image = "pihole/pihole:latest"
                  image_pull_policy = "Always"
                  env {
                      name = "TZ"
                      value = "Europe/Berlin"
                  }
                  volume_mount {
                      name = "pihole-local-etc-volume"
                      mount_path = "/etc/pihole"
                  }
                  volume_mount {
                    name = "pihole-local-dnsmasq-volume"
                    mount_path = "/etc/dnsmasq.d" 
                  }
              }

                volume {
                    name = "pihole-local-etc-volume"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.pihole.metadata[0].name
                    }
                }
                volume {
                    name = "pihole-local-dnsmasq-volume"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.dnsmasq.metadata[0].name
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "pihole" {
  metadata {
      name = "pihole"
  }

  spec {
      selector = {
          app = "pihole"
      }

      port {
          port = "8000"
          target_port = "80"
          name = "pihole-admin"
      }

      port {
          port = "53"
          target_port = "53"
          protocol = "TCP"
          name = "dns-tcp"
      }

      port {
          port = "53"
          target_port = "53"
          protocol = "UDP"
          name = "dns-udp"
      }

      external_ips = ["192.168.178.41"]
  }
}

