data "helm_repository" "mosquitto" {
    name = "mosquitto"
    url = "https://smizy.github.io/charts/"
}

resource "helm_release" "mosquitto" {
    name = "mosquitto"
    repository = data.helm_repository.mosquitto.metadata[0].name
    chart = "mosquitto"

    set {
        name = "persistence.storageClass"
        value = "nfs-client"
    }
}