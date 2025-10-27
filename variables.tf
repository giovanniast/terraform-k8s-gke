variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região do GCP para recursos regionais"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Nome do cluster GKE"
  type        = string
  default     = "curso-gke-cluster"
}

variable "app_name" {
  description = "Nome da aplicação de exemplo"
  type        = string
  default     = "app-curso"
}

variable "app_namespace" {
  description = "Namespace da aplicação"
  type        = string
  default     = "curso-app"
}

variable "app_replicas" {
  description = "Número inicial de réplicas da aplicação"
  type        = number
  default     = 3
}

variable "app_image" {
  description = "Imagem Docker da aplicação"
  type        = string
  default     = "nginx:1.25-alpine"
}

variable "hpa_min_replicas" {
  description = "Mínimo de réplicas para HPA"
  type        = number
  default     = 1
}

variable "hpa_max_replicas" {
  description = "Máximo de réplicas para HPA"
  type        = number
  default     = 3
}

variable "hpa_cpu_threshold" {
  description = "Threshold de CPU para HPA (%)"
  type        = number
  default     = 70
}

variable "hpa_memory_threshold" {
  description = "Threshold de memória para HPA (%)"
  type        = number
  default     = 80
}

variable "vpa_min_cpu" {
  description = "CPU mínima para VPA"
  type        = string
  default     = "25m"
}

variable "vpa_max_cpu" {
  description = "CPU máxima para VPA"
  type        = string
  default     = "200m"
}

variable "vpa_min_memory" {
  description = "Memória mínima para VPA"
  type        = string
  default     = "32Mi"
}

variable "vpa_max_memory" {
  description = "Memória máxima para VPA"
  type        = string
  default     = "256Mi"
}

variable "pod_cpu_request" {
  description = "CPU request para pods"
  type        = string
  default     = "50m"
}

variable "pod_cpu_limit" {
  description = "CPU limit para pods"
  type        = string
  default     = "100m"
}

variable "pod_memory_request" {
  description = "Memória request para pods"
  type        = string
  default     = "64Mi"
}

variable "pod_memory_limit" {
  description = "Memória limit para pods"
  type        = string
  default     = "128Mi"
}

variable "enable_kubecost" {
  description = "Habilitar instalação do Kubecost"
  type        = bool
  default     = true
}

variable "kubecost_version" {
  description = "Versão do Kubecost Helm chart"
  type        = string
  default     = "2.0.0"
}

variable "environment_labels" {
  description = "Labels para identificar o ambiente"
  type        = map(string)
  default = {
    env            = "stg"
    owner          = "finops"
    cost-center    = "prodam"
  }
}