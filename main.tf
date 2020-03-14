provider "kubernetes" {}

provider "helm" {}

module "pihole" {
   source = "./modules/pihole"
}

module "keepalived" {
    source = "./modules/keepalived"
}

# module "mosquitto" {
#     source = "./modules/mosquitto"
# }

resource "helm_release" "nfs-client-provisioner" {
    name = "nfs-client-provisionerr"
    chart = "stable/nfs-client-provisioner"

    set {
        name = "nfs.server"
        value = "192.168.178.2"
    }

    set {
        name = "nfs.path"
        value = "/pool/k8s-data"
    }

    set {
        name = "image.repository"
        value = "quay.io/external_storage/nfs-client-provisioner-arm"
    }

    set {
        name = "image.tag"
        value = "latest"
    }
}