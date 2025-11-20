#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

variables_txt="variables.txt"
current_context=$(kubectl config current-context)

echo -e "${GREEN}🔹 Current context: $current_context${NC}"

# Read each line from file
mapfile -t variables < "$variables_txt"

for variable in "${variables[@]}"; do
  # Skip empty lines and comments
    [[ -z "$variable" || "$variable" =~ ^[[:space:]]*# ]] && continue
  
  # Extract key and value (handle colon in values)
  key="${variable%%:*}"
  value="${variable#*:}"

  echo "Replacing $key with $value..."

  # Find and replace in .yaml files in specified folders
  find pv pvc storageclass values -type f -name "*.yaml" -exec sed -i "s|$key|$value|g" {} +

done

echo -e "${GREEN}1. Installing NFS CSI Driver...${NC}"
helm upgrade --install csi-driver-nfs "charts/csi-driver-nfs-4.11.0.tgz" -n kube-system -f values/config-csi-driver-nfs.yaml

echo -e "${GREEN}2. Applying StorageClass...${NC}"
kubectl apply -f storageclass/nfs-storage-sc.yaml
kubectl apply -f storageclass/nfs-csi-jupyterhub-sc.yaml
sleep 5

echo -e "${GREEN}3. Creating PersistentVolumes...${NC}"
kubectl apply -f pv/
sleep 10

echo -e "${GREEN}4. Creating PersistentVolumeClaims...${NC}"
kubectl apply -f pvc/
sleep 10

echo -e "${GREEN}5. Removing previous Ray CRDs...${NC}"
kubectl delete crd rayclusters.ray.io rayjobs.ray.io rayservices.ray.io --ignore-not-found
sleep 10

echo -e "${GREEN}6. Installing PostgreSQL...${NC}"

helm upgrade --install postgresql charts/postgresql-11.9.11.tgz -f values/config-postgresql.yaml
sleep 10 && helm status postgresql

helm upgrade --install postgresql-jupyterhub charts/postgresql-11.9.11.tgz -f values/config-postgresql-jupyterhub.yaml
sleep 10 && helm status postgresql-jupyterhub

echo -e "${GREEN}7. Installing JupyterHub...${NC}"
helm upgrade --install jupyterhub charts/jupyterhub-3.3.8.tgz -f values/config-jupyterhub.yaml
sleep 10 && helm status jupyterhub

echo -e "${GREEN}8. Installing MinIO...${NC}"
helm upgrade --install minio charts/minio-11.10.9.tgz -f values/config-minio.yaml
sleep 10 && helm status minio

echo -e "${GREEN}9. Installing MLflow...${NC}"
helm upgrade --install mlflow charts/mlflow-0.18.0.tgz -f values/config-mlflow.yaml
sleep 10 && helm status mlflow

echo -e "${GREEN}10. Installing KubeRay Operator...${NC}"
helm upgrade --install kuberay-operator charts/kuberay-operator-1.3.0.tgz -f values/config-kuberay-operator.yaml
sleep 5

echo -e "${GREEN}11. Installing Ray Cluster...${NC}"
helm upgrade --install raycluster charts/ray-cluster-1.3.0.tgz -f values/config-ray.yaml
sleep 10 && helm status raycluster

echo -e "${GREEN}🔹 Context used: $current_context${NC}"

# Port-forward only for minikube / local
if [[ "$current_context" == "minikube" ]]; then
  echo -e "${GREEN}12. Creating port-forward for local network access...${NC}"

  # MLflow -> port 5000
  kubectl port-forward --address 0.0.0.0 svc/mlflow 5000:5000 >/tmp/pf-mlflow.log 2>&1 &

  # JupyterHub (proxy-public) -> port 8080
  kubectl port-forward --address 0.0.0.0 svc/proxy-public 8080:80 >/tmp/pf-jupyterhub.log 2>&1 &

  # Ray Dashboard -> port 8265
  kubectl port-forward --address 0.0.0.0 svc/raycluster-kuberay-head-svc 8265:8265 >/tmp/pf-raydash.log 2>&1 &

  echo -e "${GREEN}🔹 You can now access from your LAN using your PC's IP:${NC}"
  echo -e "${GREEN}   MLflow:     http://YOUR_PC_IP:5000${NC}"
  echo -e "${GREEN}   JupyterHub: http://YOUR_PC_IP:8080${NC}"
  echo -e "${GREEN}   Ray Dash:   http://YOUR_PC_IP:8265${NC}"
fi