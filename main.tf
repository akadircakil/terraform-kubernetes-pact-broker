resource "kubernetes_config_map" "pact_broker_postgresql_config" {
  metadata {
    name      = "${var.name}-postgresql"
    namespace = var.namespace
  }

  data = {
    "POSTGRES_DB" : "pact-broker"
    "POSTGRES_USER" : var.pact_broker_postgres_username
    "POSTGRES_PASSWORD" : var.pact_broker_postgres_password
  }
}

resource "kubernetes_config_map" "pact_broker_config" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = {
    "PACT_BROKER_BASIC_AUTH_USERNAME" : var.pact_broker_basic_auth_username
    "PACT_BROKER_BASIC_AUTH_PASSWORD" : var.pact_broker_basic_auth_password
    "PACT_BROKER_DATABASE_ADAPTER" : "postgres"
    "PACT_BROKER_DATABASE_USERNAME" : var.pact_broker_postgres_username
    "PACT_BROKER_DATABASE_PASSWORD" : var.pact_broker_postgres_password
    "PACT_BROKER_DATABASE_HOST" : "${var.name}-postgresql"
    "PACT_BROKER_DATABASE_NAME" : "pact-broker"
    "PACT_BROKER_DATABASE_PORT" : "5432"
  }
}

resource "kubernetes_service" "pact_broker_postgresql" {
  metadata {
    name      = "${var.name}-postgresql"
    namespace = var.namespace
  }

  spec {
    port {
      name = "pact-broker-postgresql"
      port = 5432
    }

    selector = {
      app = "${var.name}-postgresql"
    }

    cluster_ip = "None"
    type       = "ClusterIP"
  }
}

resource "kubernetes_service" "pact_broker" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9292
      target_port = "http"
    }

    selector = {
      app = var.name
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_stateful_set" "pact_broker_postgresql" {
  metadata {
    name      = "${var.name}-postgresql"
    namespace = var.namespace
  }

  spec {
    service_name = "${var.name}-postgresql"
    replicas     = 1

    selector {
      match_labels = {
        app = "${var.name}-postgresql"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.name}-postgresql"
        }
      }

      spec {
        container {
          name  = "${var.name}-postgresql"
          image = "postgres:13.1-alpine"
          env_from {
            config_map_ref {
              name = "${var.name}-postgresql"
            }
          }
          port {
            container_port = 5432
          }
          volume_mount {
            name       = "${var.name}-postgresql"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "postgres"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name      = "${var.name}-postgresql"
        namespace = var.namespace
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class_name
        resources {
          requests = {
            "storage" = var.storage_size
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.pact_broker_postgresql_config,
  ]
}

resource "kubernetes_deployment" "pact_broker" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      app = var.name
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          name  = var.name
          image = "pactfoundation/pact-broker:latest"

          env_from {
            config_map_ref {
              name = var.name
            }
          }

          env {
            name  = "PACT_BROKER_PORT"
            value = "9292"
          }

          port {
            container_port = 9292
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.pact_broker_config,
    kubernetes_stateful_set.pact_broker_postgresql
  ]
}
