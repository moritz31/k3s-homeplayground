resource "helm_release" "prometheus-operator" {
  name = "prometheus-operator"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "prometheus-operator"

  values = [
      "${file("modules/helm/prometheus-values.yaml")}"
  ]

  set {
      name = "prometheusOperator.tlsProxy.enabled"
      value = "false"
  }

    set {
      name = "prometheusOperator.admissionWebhooks.enabled"
      value = "false"
  }
}
