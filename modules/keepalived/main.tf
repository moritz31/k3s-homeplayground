data "helm_repository" "private" {
    name = "private"
    url = "https://moritz31.github.io/helm/"
}

resource "helm_release" "keepalived" {
    name = "keepalived"
    repository = data.helm_repository.private.metadata[0].name
    chart = "keepalived"
}