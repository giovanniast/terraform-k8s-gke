# ============================================
# CLUSTER OUTPUTS
# ============================================

output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.autopilot_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster"
  value       = google_container_cluster.autopilot_cluster.endpoint
  sensitive   = true
}

output "cluster_location" {
  description = "Localização do cluster"
  value       = google_container_cluster.autopilot_cluster.location
}

output "cluster_ca_certificate" {
  description = "Certificado CA do cluster"
  value       = google_container_cluster.autopilot_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

# ============================================
# KUBERNETES OUTPUTS
# ============================================

output "app_namespace" {
  description = "Namespace da aplicação"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "app_deployment_name" {
  description = "Nome do deployment"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "app_service_name" {
  description = "Nome do service"
  value       = kubernetes_service.app.metadata[0].name
}

# ============================================
# KUBECTL CONFIGURATION
# ============================================

output "configure_kubectl" {
  description = "Comando para configurar kubectl"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# ============================================
# KUBECOST ACCESS
# ============================================

output "kubecost_access" {
  description = "Como acessar o Kubecost Dashboard"
  value = <<-EOT
    
    ============================================
     ACESSAR KUBECOST DASHBOARD
    ============================================
    
    1. Configure kubectl:
       gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}
    
    2. Execute o port-forward:
       kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
    
    3. Abra no navegador:
       http://localhost:9090
    
    4. Recursos disponíveis:
       - Custo por namespace
       - Custo por deployment
       - Custo por pod
       - Recomendações de economia
       - Eficiência de recursos
    
    ============================================
  EOT
}

# ============================================
# VERIFICATION COMMANDS
# ============================================

output "verify_deployment" {
  description = "Comandos para verificar o deployment"
  value       = <<-EOT
    
    ============================================
     VERIFICAR DEPLOYMENT
    ============================================
    
    # Ver todos os recursos
    kubectl get all -n ${var.app_namespace}
    
    # Ver pods
    kubectl get pods -n ${var.app_namespace}
    
    # Ver logs
    kubectl logs -n ${var.app_namespace} -l app=${var.app_name}
    
    # Descrever deployment
    kubectl describe deployment ${var.app_name} -n ${var.app_namespace}
    
    ============================================
  EOT
}

output "verify_autoscaling" {
  description = "Comandos para verificar autoscaling"
  value       = <<-EOT
    
    ============================================
     VERIFICAR AUTOSCALING
    ============================================
    
    # Ver HPA
    kubectl get hpa -n ${var.app_namespace}
    kubectl describe hpa ${var.app_name}-hpa -n ${var.app_namespace}
    
    # Ver VPA
    kubectl get vpa -n ${var.app_namespace}
    kubectl describe vpa ${var.app_name}-vpa -n ${var.app_namespace}
    
    # Acompanhar HPA em tempo real
    kubectl get hpa -n ${var.app_namespace} -w
    
    ============================================
  EOT
}

output "test_autoscaling" {
  description = "Comandos para testar autoscaling"
  value       = <<-EOT
    
    ============================================
     TESTAR AUTOSCALING
    ============================================
    
    # Gerar carga
    kubectl run -n ${var.app_namespace} load-generator \
      --image=busybox --restart=Never \
      -- /bin/sh -c "while true; do wget -q -O- http://${var.app_name}-service; done"
    
    # Acompanhar scaling
    watch kubectl get hpa,pods -n ${var.app_namespace}
    
    # Limpar teste
    kubectl delete pod load-generator -n ${var.app_namespace}
    
    ============================================
  EOT
}

output "access_application" {
  description = "Como acessar a aplicação"
  value       = <<-EOT
    
    ============================================
     ACESSAR APLICAÇÃO
    ============================================
    
    # Obter IP externo (aguarde alguns minutos)
    kubectl get svc ${var.app_name}-service -n ${var.app_namespace}
    
    # Ou este comando:
    export SERVICE_IP=$(kubectl get svc ${var.app_name}-service -n ${var.app_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "APP URL: http://$SERVICE_IP"
    
    # Testar
    curl http://$SERVICE_IP
    
    ============================================
  EOT
}

# ============================================
# COST INFORMATION
# ============================================

output "cost_estimates" {
  description = "Estimativa de custos"
  value       = <<-EOT
    
    ============================================
     ESTIMATIVA DE CUSTOS (USD/mês)
    ============================================
    
     GKE Autopilot:
       - Control Plane: GRÁTIS
       - Pods (${var.app_replicas}x ${var.app_image}): ~$${var.app_replicas * 2}-${var.app_replicas * 3}/mês
       ${var.enable_kubecost ? "- Kubecost pods: ~$3-5/mês" : ""}
       
     Load Balancer: ~$18/mês
    
    ${var.enable_kubecost ? "Storage (Kubecost): ~$2/mês" : ""}
    
     TOTAL ESTIMADO: $${var.enable_kubecost ? "28-35" : "23-28"}/mês
    
    ⚡ DICAS PARA REDUZIR:
       - Use ClusterIP em vez de LoadBalancer
       - Delete quando não estiver usando
       - Configure Cloud Scheduler para pausar
    
    ============================================
  EOT
}

# ============================================
# CLEANUP COMMANDS
# ============================================

output "cleanup_commands" {
  description = "Comandos para limpar recursos"
  value       = <<-EOT
    
    ============================================
     LIMPAR RECURSOS
    ============================================
    
    # Deletar aplicação (mantém cluster)
    terraform destroy -target=kubernetes_deployment.app
    terraform destroy -target=kubernetes_service.app
    
    # Deletar tudo
    terraform destroy
    
    # Verificar limpeza
    gcloud container clusters list --project=prodam-d6584-finops-labs
    
    ============================================
  EOT
}