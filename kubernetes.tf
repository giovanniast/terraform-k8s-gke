# ============================================
# KUBERNETES.TF -
# ============================================
# NAMESPACE
# ============================================

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.app_namespace
    
    labels = merge(
      var.environment_labels,
      {
        app        = var.app_name
        managed-by = "terraform"
      }
    )
  }
  
  depends_on = [google_container_cluster.autopilot_cluster]
}

# ============================================
# DEPLOYMENT
# ============================================

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    
    labels = {
      app = var.app_name
    }
  }
  
  spec {
    replicas = var.app_replicas
    
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      
      spec {
        container {
          name  = "app"
          image = var.app_image
          
          port {
            container_port = 80
            name          = "http"
          }
          
          # Resources otimizados para cargas baixas
          resources {
            requests = {
              cpu    = var.pod_cpu_request
              memory = var.pod_memory_request
            }
            
            limits   = {
              cpu    = var.pod_cpu_limit
              memory = var.pod_memory_limit
            }
          }
          
          # Health checks
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_namespace.app_namespace]
}

# ============================================
# SERVICE
# ============================================

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    
    labels = {
      app = var.app_name
    }
  }
  
  spec {
    selector = {
      app = var.app_name
    }
    
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    
    type = "LoadBalancer"
  }
  
  depends_on = [kubernetes_deployment.app]
}

# ============================================
# HPA - HORIZONTAL POD AUTOSCALER (CORRIGIDO)
# ============================================

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }
    
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas
    
    # ============================================
    # selectPolicy é OBRIGATÓRIO
    # ============================================
    behavior {
      # Scale Down - Comportamento conservador
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"  # Política mais conservadora
        
        # Remove no máximo 1 pod por minuto
        policy {
          type           = "Pods"
          value          = 1
          period_seconds = 60
        }
        
        # Ou remove 10% dos pods por minuto
        policy {
          type           = "Percent"
          value          = 10
          period_seconds = 60
        }
      }
      
      # Scale Up - Comportamento mais agressivo
      scale_up {
        stabilization_window_seconds = 60
        select_policy                = "Max"  # Política mais agressiva
        
        # Adiciona até 2 pods por minuto
        policy {
          type           = "Pods"
          value          = 2
          period_seconds = 60
        }
        
        # Ou adiciona 50% dos pods por minuto
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
    }
    
    # ============================================
    # METRICS - CPU
    # ============================================
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_threshold
        }
      }
    }
    
    # ============================================
    # METRICS - MEMORY
    # ============================================
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_memory_threshold
        }
      }
    }
  }
  
  depends_on = [kubernetes_deployment.app]
}

# ============================================
# OUTPUTS ÚTEIS
# ============================================

output "deployment_status" {
  description = "Status do deployment"
  value = {
    name      = kubernetes_deployment.app.metadata[0].name
    namespace = kubernetes_deployment.app.metadata[0].namespace
    replicas  = var.app_replicas
  }
}

output "hpa_config" {
  description = "Configuração do HPA"
  value = {
    name         = "${var.app_name}-hpa"
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas
    cpu_target   = var.hpa_cpu_threshold
    memory_target = var.hpa_memory_threshold
  }
}
