#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Uninstalling Helm releases...${NC}"
helm uninstall raycluster || true
helm uninstall kuberay-operator || true
helm uninstall mlflow || true
helm uninstall minio || true
helm uninstall jupyterhub || true
helm uninstall postgresql-jupyterhub || true
helm uninstall postgresql || true
helm uninstall csi-driver-nfs -n kube-system || true

echo -e "${GREEN}2. Terminating JupyterHub user pods...${NC}"
kubectl delete pod -l component=singleuser-server --grace-period=0 --force || true
sleep 10

echo -e "${GREEN}3. Deleting PersistentVolumeClaims...${NC}"
kubectl delete -f pvc/ --ignore-not-found
sleep 5

echo -e "${GREEN}4. Deleting PersistentVolumes...${NC}"
kubectl delete -f pv/ --ignore-not-found
sleep 5

echo -e "${GREEN}5. Removing StorageClass resources...${NC}"
kubectl delete -f storageclass/nfs-storage-sc.yaml --ignore-not-found
kubectl delete -f storageclass/nfs-csi-jupyterhub-sc.yaml --ignore-not-found
sleep 3

echo -e "${GREEN}6. Purging Ray CustomResourceDefinitions...${NC}"
kubectl delete crd rayclusters.ray.io rayjobs.ray.io rayservices.ray.io --ignore-not-found

echo -e "${GREEN}✅ Teardown completed successfully.${NC}"