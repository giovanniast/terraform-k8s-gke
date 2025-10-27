# Valores das variáveis
project_id   = "prodam-d6584-finops-labs"
region       = "us-central1"
cluster_name = "cluster-curso-finops"

# Config aplicação
app_name     = "app-curso"
app_replicas = 3
app_image    = "nginx:1.25-alpine"

# HPA
hpa_min_replicas     = 1
hpa_max_replicas     = 5
hpa_cpu_threshold    = 70
hpa_memory_threshold = 80

# VPA
vpa_min_cpu    = "25m"
vpa_max_cpu    = "200m"
vpa_min_memory = "32Mi"
vpa_max_memory = "256Mi"

# Resources dos pods
pod_cpu_request    = "50m"
pod_cpu_limit      = "100m"
pod_memory_request = "64Mi"
pod_memory_limit   = "128Mi"

# Kubecost
enable_kubecost = true

# Labels
environment_labels = {
  env            = "stg"
  owner          = "giovanni"
  cost-center    = "curso-finops"
}