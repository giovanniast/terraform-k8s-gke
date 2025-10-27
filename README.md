##
# - Antes de tudo
# Etapa 1: Criar apenas o cluster GKE
terraform apply -target=google_container_cluster.autopilot_cluster

# Etapa 2: Criar o resto (Kubernetes resources)
terraform apply



# GKE Course Environment - Terraform
# 
# ## 📋 Estrutura do Projeto
# 
# ```
# terraform-gke-curso/
# ├── main.tf              # APIs e recursos principais
# ├── variables.tf         # Definição de variáveis
# ├── outputs.tf           # Outputs do Terraform
# ├── providers.tf         # Configuração de providers
# ├── versions.tf          # Versões e requirements
# ├── gke.tf              # Cluster GKE Autopilot
# ├── kubernetes.tf        # Recursos Kubernetes
# ├── kubecost.tf         # Instalação do Kubecost
# ├── terraform.tfvars    # Valores das variáveis
# └── README.md           # Este arquivo
# ```
# 
# ## Como Usar
# 
# ### 1. Pré-requisitos
# 
# ```bash
# # Instalar Terraform
# brew install terraform  # MacOS
# # ou baixe em: https://www.terraform.io/downloads
# 
# # Instalar gcloud CLI
# # https://cloud.google.com/sdk/docs/install
# 
# # Autenticar no GCP
# gcloud auth application-default login
# ```
# 
# ### 2. Configurar Variáveis
# 
# Crie o arquivo `terraform.tfvars`:
# 
# ```hcl
# project_id      = "seu-projeto-gcp"
# region          = "us-central1"
# cluster_name    = "curso-cluster"
# app_name        = "app-curso"
# app_replicas    = 3
# enable_kubecost = true
# ```
# 
# ### 3. Executar Terraform
# 
# ```bash
# # Inicializar
# terraform init
# 
# # Planejar
# terraform plan
# 
# # Aplicar
# terraform apply
# 
# # Ver outputs
# terraform output
# ```
# 
# ### 4. Configurar kubectl
# 
# ```bash
# gcloud container clusters get-credentials curso-cluster \
#   --region us-central1 --project seu-projeto-gcp
# ```
# 
# ### 5. Verificar Recursos
# 
# ```bash
# kubectl get all -n curso-app
# kubectl get hpa -n curso-app
# kubectl get vpa -n curso-app
# ```
# 
# ### 6. Acessar Kubecost
# 
# ```bash
# kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
# # Abra: http://localhost:9090
# ```
# 
# ##  Customização
# 
# ### Ajustar Resources
# 
# No `terraform.tfvars`:
# 
# ```hcl
# pod_cpu_request    = "100m"
# pod_memory_request = "128Mi"
# hpa_max_replicas   = 10
# ```
# 
# ### Desabilitar Kubecost
# 
# ```hcl
# enable_kubecost = false
# ```
# 
# ### Mudar Imagem
# 
# ```hcl
# app_image = "gcr.io/seu-projeto/sua-app:v1"
# ```
# 
# ## Limpar Recursos
# 
# ```bash
# # Deletar tudo
# terraform destroy
# 
# # Deletar apenas a aplicação
# terraform destroy -target=kubernetes_deployment.app
# ```
# 
# ##  Custos Estimados
# 
# - **GKE Autopilot**: $5-10/mês (3 pods)
# - **Load Balancer**: $18/mês
# - **Kubecost**: $3-5/mês
# - **Storage**: $2/mês
# - **TOTAL**: ~$28-35/mês
# 
# ##  Troubleshooting
# 
# ### Cluster não cria
# ```bash
# # Verificar APIs habilitadas
# gcloud services list --enabled --project=seu-projeto
# ```
# 
# ### VPA não funciona
# ```bash
# # VPA é habilitado automaticamente no Autopilot
# kubectl get vpa -n curso-app
# ```
# 
# ### Kubecost não instala
# ```bash
# # Verificar namespace
# kubectl get ns kubecost
# 
# # Ver logs
# kubectl logs -n kubecost -l app=kubecost
# ```
# 
# ##  Referências
# 
# - [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
# - [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
# - [Kubecost](https://www.kubecost.com/)
