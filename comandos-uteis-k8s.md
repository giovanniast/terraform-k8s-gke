# Guia de Comandos Essenciais - Kubernetes e GKE

Antes de rodar os comandos, substitua os nomes do ambiente

```
PROJECT_ID    ="{seu-projeto-gcp}"  # Exemplo: projeto-dev
CLUSTER_NAME  ="{seu-cluster}"      # Exemplo: cluster-dev
REGION        ="{sua-regiao}"       # Exemplo: us-central1
NAMESPACE     ="{seu-namespace}"    # Exemplo: curso-app
APP_NAME      ="{nome-da-app}"      # Exemplo: app-curso
SERVICE_NAME  ="{nome-do-service}"  # Exemplo: app-curso-service
```

---

## **1. Configuração Inicial do Cluster**

### **Autenticar no GCP**

```bash
# Login no GCP
gcloud auth login

# Configurar projeto padrão
gcloud config set project PROJECT_ID

# Verificar configuração
gcloud config list
```

### **Conectar ao Cluster GKE**

```bash
# Obter credenciais do cluster
gcloud container clusters get-credentials CLUSTER_NAME \
  --region REGION \
  --project PROJECT_ID

# Verificar conexão
kubectl cluster-info

# Ver contexto atual
kubectl config current-context
```

---

## **2. Comandos Básicos de Visualização**

### **Listar Recursos**

```bash
# Ver todos os nodes do cluster
kubectl get nodes

# Ver nodes com labels
kubectl get nodes --show-labels

# Ver nodes com detalhes de recursos
kubectl get nodes -o wide

# Listar todos os namespaces
kubectl get namespaces

# Ou abreviado
kubectl get ns

# Ver todos os recursos em um namespace
kubectl get all -n NAMESPACE

# Ver recursos em todos os namespaces
kubectl get all -A
```

### **Pods**

```bash
# Listar pods no namespace
kubectl get pods -n NAMESPACE

# Ver pods com mais detalhes (node, IP, etc)
kubectl get pods -n NAMESPACE -o wide

# Ver pods de uma aplicação específica
kubectl get pods -n NAMESPACE -l app=APP_NAME

# Ver pods em tempo real (watch mode)
kubectl get pods -n NAMESPACE -w

# Ver pods com seus containers
kubectl get pods -n NAMESPACE -o jsonpath='{range .items[*]{.metadata.name{"\t"{.spec.containers[*].name{"\n"{end'

# Ver pods que estão com problema
kubectl get pods -n NAMESPACE --field-selector=status.phase!=Running
```

### **Deployments**

```bash
# Listar deployments
kubectl get deployments -n NAMESPACE

# Ver deployment específico
kubectl get deployment APP_NAME -n NAMESPACE

# Ver status detalhado
kubectl get deployment APP_NAME -n NAMESPACE -o wide

# Ver réplicas atuais
kubectl get deployment APP_NAME -n NAMESPACE -o jsonpath='{.spec.replicas'
```

### **Services**

```bash
# Listar services
kubectl get services -n NAMESPACE

# Ou abreviado
kubectl get svc -n NAMESPACE

# Ver service específico
kubectl get svc SERVICE_NAME -n NAMESPACE

# Ver IP externo (se LoadBalancer)
kubectl get svc SERVICE_NAME -n NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip'

# Ver todas as portas expostas
kubectl get svc -n NAMESPACE -o jsonpath='{range .items[*]{.metadata.name{"\t"{.spec.ports[*].port{"\n"{end'
```

---

## **3. Comandos de Diagnóstico**

### **Describe (Detalhes Completos)**

```bash
# Descrever node
kubectl describe node {nome-do-node

# Descrever pod
kubectl describe pod {nome-do-pod -n NAMESPACE

# Descrever deployment
kubectl describe deployment APP_NAME -n NAMESPACE

# Descrever service
kubectl describe service SERVICE_NAME -n NAMESPACE
```

### **Logs**

```bash
# Ver logs de um pod
kubectl logs {nome-do-pod -n NAMESPACE

# Ver logs em tempo real (follow)
kubectl logs {nome-do-pod -n NAMESPACE -f

# Ver últimas 50 linhas
kubectl logs {nome-do-pod -n NAMESPACE --tail=50

# Ver logs de todos os pods de uma app
kubectl logs -n NAMESPACE -l app=APP_NAME

# Ver logs de todos os pods com follow
kubectl logs -n NAMESPACE -l app=APP_NAME -f

# Ver logs de container específico (se pod tem múltiplos containers)
kubectl logs {nome-do-pod -n NAMESPACE -c {nome-do-container

# Ver logs anteriores (se pod reiniciou)
kubectl logs {nome-do-pod -n NAMESPACE --previous
```

### **Eventos**

```bash
# Ver eventos do namespace
kubectl get events -n NAMESPACE

# Ver eventos ordenados por tempo
kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'

# Ver eventos em tempo real
kubectl get events -n NAMESPACE -w

# Ver eventos de todos os namespaces
kubectl get events -A --sort-by='.lastTimestamp'
```

### **Uso de Recursos**

```bash
# Ver uso de recursos dos nodes
kubectl top nodes

# Ver uso de recursos dos pods
kubectl top pods -n NAMESPACE

# Ver pods que mais consomem CPU
kubectl top pods -n NAMESPACE --sort-by=cpu

# Ver pods que mais consomem memória
kubectl top pods -n NAMESPACE --sort-by=memory
```

---

## **4. Comandos de Acesso**

### **Port-Forward (Acessar Aplicação Localmente)**

```bash
# Port-forward de um pod
kubectl port-forward pod/{nome-do-pod -n NAMESPACE 8080:80

# Port-forward de um service (recomendado)
kubectl port-forward svc/SERVICE_NAME -n NAMESPACE 8080:80

# Port-forward do Kubecost
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090

# Port-forward em background
kubectl port-forward svc/SERVICE_NAME -n NAMESPACE 8080:80 &

# Parar port-forward em background
kill %1  # ou pkill -f "port-forward"
```

### **Exec (Executar Comandos Dentro do Pod)**

```bash
# Abrir shell interativo no pod
kubectl exec -it {nome-do-pod -n NAMESPACE -- /bin/sh

# Ou bash (se disponível)
kubectl exec -it {nome-do-pod -n NAMESPACE -- /bin/bash

# Executar comando único
kubectl exec {nome-do-pod -n NAMESPACE -- ls -la

# Executar em container específico
kubectl exec -it {nome-do-pod -n NAMESPACE -c {nome-do-container -- /bin/sh

# Ver variáveis de ambiente do pod
kubectl exec {nome-do-pod -n NAMESPACE -- env

# Testar conectividade de dentro do pod
kubectl exec {nome-do-pod -n NAMESPACE -- curl http://outro-service:80
```

---

## **5. Comandos de Gerenciamento**

### **Escalar Deployment**

```bash
# Escalar para número específico de réplicas
kubectl scale deployment APP_NAME --replicas=5 -n NAMESPACE

# Escalar para zero (desligar)
kubectl scale deployment APP_NAME --replicas=0 -n NAMESPACE

# Escalar para 3 (ligar novamente)
kubectl scale deployment APP_NAME --replicas=3 -n NAMESPACE

# Ver status do scaling
kubectl get deployment APP_NAME -n NAMESPACE -w
```

### **Atualizar Deployment**

```bash
# Atualizar imagem do container
kubectl set image deployment/APP_NAME \
  {nome-do-container={nova-imagem:tag \
  -n NAMESPACE

# Exemplo:
kubectl set image deployment/APP_NAME \
  nginx=nginx:1.25-alpine \
  -n NAMESPACE

# Reiniciar deployment (recreate pods)
kubectl rollout restart deployment/APP_NAME -n NAMESPACE

# Ver status do rollout
kubectl rollout status deployment/APP_NAME -n NAMESPACE

# Ver histórico de rollouts
kubectl rollout history deployment/APP_NAME -n NAMESPACE

# Fazer rollback (voltar versão anterior)
kubectl rollout undo deployment/APP_NAME -n NAMESPACE

# Rollback para versão específica
kubectl rollout undo deployment/APP_NAME -n NAMESPACE --to-revision=2
```

### **Deletar Recursos**

```bash
# Deletar pod específico
kubectl delete pod {nome-do-pod -n NAMESPACE

# Deletar todos os pods de uma app
kubectl delete pods -n NAMESPACE -l app=APP_NAME

# Deletar deployment
kubectl delete deployment APP_NAME -n NAMESPACE

# Deletar service
kubectl delete service SERVICE_NAME -n NAMESPACE

# Deletar namespace (cuidado!)
kubectl delete namespace NAMESPACE

# Deletar tudo em um namespace
kubectl delete all --all -n NAMESPACE

# Forçar deleção de pod travado
kubectl delete pod {nome-do-pod -n NAMESPACE --force --grace-period=0
```

---

## **6. HPA e VPA**

### **Horizontal Pod Autoscaler (HPA)**

```bash
# Ver HPA
kubectl get hpa -n NAMESPACE

# Ver HPA com detalhes
kubectl get hpa APP_NAME-hpa -n NAMESPACE

# Descrever HPA (ver métricas atuais)
kubectl describe hpa APP_NAME-hpa -n NAMESPACE

# Ver HPA em tempo real
kubectl get hpa -n NAMESPACE -w

# Criar HPA via comando
kubectl autoscale deployment APP_NAME \
  --cpu-percent=70 \
  --min=2 \
  --max=10 \
  -n NAMESPACE

# Deletar HPA
kubectl delete hpa APP_NAME-hpa -n NAMESPACE
```

### **Vertical Pod Autoscaler (VPA)**

```bash
# Ver VPA
kubectl get vpa -n NAMESPACE

# Descrever VPA (ver recomendações)
kubectl describe vpa APP_NAME-vpa -n NAMESPACE

# Ver recomendações de recursos
kubectl get vpa APP_NAME-vpa -n NAMESPACE -o jsonpath='{.status.recommendation'
```

---

## **7. Comandos de Teste**

### **Testar Autoscaling**

```bash
# Gerar carga no deployment
kubectl run load-generator \
  --image=busybox \
  --restart=Never \
  -n NAMESPACE \
  -- /bin/sh -c "while true; do wget -q -O- http://SERVICE_NAME; done"

# Acompanhar HPA reagindo
watch kubectl get hpa,pods -n NAMESPACE

# Parar teste de carga
kubectl delete pod load-generator -n NAMESPACE
```

### **Testar Conectividade**

```bash
# Criar pod temporário para testes
kubectl run test-pod \
  --image=busybox \
  --rm -it \
  -n NAMESPACE \
  -- /bin/sh

# Dentro do pod, testar:
# wget http://SERVICE_NAME
# nslookup SERVICE_NAME
# ping SERVICE_NAME

# Teste rápido de conectividade
kubectl run curl-test \
  --image=curlimages/curl:latest \
  --rm -it \
  -n NAMESPACE \
  -- curl http://SERVICE_NAME
```

---

## **8. Backup e Export**

### **Exportar Recursos**

```bash
# Exportar deployment para YAML
kubectl get deployment APP_NAME -n NAMESPACE -o yaml > deployment-backup.yaml

# Exportar service
kubectl get service SERVICE_NAME -n NAMESPACE -o yaml > service-backup.yaml

# Exportar tudo do namespace
kubectl get all -n NAMESPACE -o yaml > namespace-backup.yaml

# Exportar configmap
kubectl get configmap {nome-configmap -n NAMESPACE -o yaml > configmap-backup.yaml

# Exportar secret (base64 encoded)
kubectl get secret {nome-secret -n NAMESPACE -o yaml > secret-backup.yaml
```

---

## **9. ConfigMaps e Secrets**

### **ConfigMaps**

```bash
# Listar configmaps
kubectl get configmaps -n NAMESPACE

# Ver conteúdo de configmap
kubectl describe configmap {nome-configmap -n NAMESPACE

# Criar configmap de arquivo
kubectl create configmap {nome-configmap \
  --from-file=config.txt \
  -n NAMESPACE

# Criar configmap de literal
kubectl create configmap {nome-configmap \
  --from-literal=KEY=value \
  -n NAMESPACE

# Editar configmap
kubectl edit configmap {nome-configmap -n NAMESPACE

# Deletar configmap
kubectl delete configmap {nome-configmap -n NAMESPACE
```

### **Secrets**

```bash
# Listar secrets
kubectl get secrets -n NAMESPACE

# Ver secret (valores em base64)
kubectl get secret {nome-secret -n NAMESPACE -o yaml

# Decodificar valor do secret
kubectl get secret {nome-secret -n NAMESPACE -o jsonpath='{.data.password' | base64 -d

# Criar secret
kubectl create secret generic {nome-secret \
  --from-literal=username=admin \
  --from-literal=password=senha123 \
  -n NAMESPACE

# Deletar secret
kubectl delete secret {nome-secret -n NAMESPACE
```

---

## **10. Comandos Úteis do GCloud**

### **Cluster Management**

```bash
# Listar clusters
gcloud container clusters list --project=PROJECT_ID

# Ver detalhes do cluster
gcloud container clusters describe CLUSTER_NAME \
  --region REGION \
  --project PROJECT_ID

# Listar node pools
gcloud container node-pools list \
  --cluster=CLUSTER_NAME \
  --region=REGION \
  --project=PROJECT_ID

# Redimensionar node pool
gcloud container clusters resize CLUSTER_NAME \
  --node-pool {nome-node-pool \
  --num-nodes 3 \
  --region REGION \
  --project PROJECT_ID
```

### **Imagens no GCR**

```bash
# Listar imagens no GCR
gcloud container images list \
  --project=PROJECT_ID

# Ver tags de uma imagem
gcloud container images list-tags \
  gcr.io/PROJECT_ID/{nome-imagem

# Deletar imagem
gcloud container images delete \
  gcr.io/PROJECT_ID/{nome-imagem:tag \
  --quiet
```

---

## **11. Aliases Úteis**

Adicione ao seu `~/.bashrc` ou `~/.zshrc`:

```bash
# Aliases básicos
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'

# Aliases com namespace
alias kn='kubectl -n NAMESPACE'
alias knp='kubectl get pods -n NAMESPACE'
alias kns='kubectl get svc -n NAMESPACE'
alias knd='kubectl get deployments -n NAMESPACE'

# Describe
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias kex='kubectl exec -it'

# Port-forward
alias kpf='kubectl port-forward'

# Aplicar após definir:
source ~/.bashrc  # ou source ~/.zshrc
```

---

## **12. Script de Status Completo**

Crie um script `cluster-status.sh`:

```bash
#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Suas variáveis
PROJECT_ID="PROJECT_ID:-seu-projeto"
CLUSTER_NAME="CLUSTER_NAME:-seu-cluster"
REGION="REGION:-us-central1"
NAMESPACE="NAMESPACE:-default"

echo -e "BLUE============================================NC"
echo -e "BLUE STATUS DO CLUSTERNC"
echo -e "BLUE============================================NC"
echo ""

echo -e "YELLOW Informações do Cluster:NC"
echo "  Projeto: PROJECT_ID"
echo "  Cluster: CLUSTER_NAME"
echo "  Região: REGION"
echo "  Namespace: NAMESPACE"
echo ""

echo -e "YELLOW  Nodes:NC"
kubectl get nodes
echo ""

echo -e "YELLOW Pods (NAMESPACE):NC"
kubectl get pods -n NAMESPACE
echo ""

echo -e "YELLOW Services (NAMESPACE):NC"
kubectl get svc -n NAMESPACE
echo ""

echo -e "YELLOW HPA (NAMESPACE):NC"
kubectl get hpa -n NAMESPACE 2>/dev/null || echo "  Nenhum HPA encontrado"
echo ""

echo -e "YELLOW VPA (NAMESPACE):NC"
kubectl get vpa -n NAMESPACE 2>/dev/null || echo "  Nenhum VPA encontrado"
echo ""

echo -e "YELLOW Uso de Recursos:NC"
kubectl top nodes 2>/dev/null || echo "  Metrics server não disponível"
echo ""

echo -e "GREEN Status verificado!NC"
```

**Usar:**

```bash
chmod +x cluster-status.sh
./cluster-status.sh
```

---

## **13. Recursos Adicionais**

```bash
# Documentação oficial
kubectl explain pod
kubectl explain deployment
kubectl explain service

# Ver API resources disponíveis
kubectl api-resources

# Ver versões de API
kubectl api-versions

# Ver configuração completa do kubectl
kubectl config view

# Ver todos os contextos
kubectl config get-contexts

# Mudar de contexto
kubectl config use-context {nome-contexto

# Definir namespace padrão
kubectl config set-context --current --namespace=NAMESPACE
```
