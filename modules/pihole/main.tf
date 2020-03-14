data "helm_repository" "pihole" {
    name = "pihole"
    url = "https://mojo2600.github.io/pihole-kubernetes/"
}

resource "helm_release" "pihole" {
    name = "pihole"
    repository = data.helm_repository.pihole.metadata[0].name
    chart = "pihole"

    set {
        name = "persistentVolumeClaim.enabled"
        value = "true"
    }

    set {
        name = "persistentVolumeClaim.storageClass"
        value = "nfs-client"
    }

    set {
        name = "ingress.enabled"
        value = "true"
    }
}