# ============================================
# KUBECOST - MONITORAMENTO DE CUSTOS
# ============================================

resource "kubernetes_namespace" "kubecost" {
  count = var.enable_kubecost ? 1 : 0
  
  metadata {
    name = "kubecost"
    
    labels = {
      app        = "kubecost"
      managed-by = "terraform"
    }
  }
  
  depends_on = [google_container_cluster.autopilot_cluster]
}

resource "helm_release" "kubecost" {
  count = var.enable_kubecost ? 1 : 0
  
  name       = "kubecost"
  repository = "oci://public.ecr.aws/kubecost"
  chart      = "cost-analyzer"
  version    = var.kubecost_version
  namespace  = kubernetes_namespace.kubecost[0].metadata[0].name
  
  values = [
    yamlencode({
      global = {
        prometheus = {
          enabled = true
          fqdn    = "http://prometheus-server.kubecost.svc.cluster.local"
        }
      }
      
      kubecostProductConfigs = {
        clusterName = var.cluster_name
        
        gcpConfig = {
          enabled   = true
          projectID = var.project_id
        }
      }
      
      kubecostDeployment = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
      
      prometheus = {
        server = {
          resources = {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          
          persistentVolume = {
            enabled = true
            size    = "10Gi"
          }
        }
        
        alertmanager = {
          enabled = false
        }
        pushgateway = {
          enabled = false
        }
      }
    })
  ]
  
  timeout = 600
  
  depends_on = [
    kubernetes_namespace.kubecost[0],
    google_container_cluster.autopilot_cluster
  ]
}