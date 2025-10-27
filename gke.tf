# ============================================
# CLUSTER GKE AUTOPILOT
# ============================================
# Autopilot = Google gerencia nodes automaticamente
# Você paga apenas pelos pods em execução
# Ideal para cursos e ambientes de aprendizado
# ============================================

resource "google_container_cluster" "autopilot_cluster" {
  name     = var.cluster_name
  location = var.region
  
  # IMPORTANTE: Habilita modo Autopilot
  enable_autopilot = true
  
  # Configurações de release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Configurações de rede
  network    = "default"
  subnetwork = "default"
  
  # IP allocation para pods e services
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }
  
  # Vertical Pod Autoscaling habilitado
  vertical_pod_autoscaling {
    enabled = true
  }
  
  # Monitoramento e logging
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    
    managed_prometheus {
      enabled = true
    }
  }
  
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  
  # Cost allocation tracking
  resource_labels = var.environment_labels

  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api
  ]
}

  # NOTA: Em clusters Autopilot, o NAP é gerenciado
  # automaticamente pelo Google. Esta config é para
  # clusters Standard mode apenas.