#!/bin/bash
set -euo pipefail

NAMESPACE="nfs-server-storage"

echo "Removing NFS Ganesha Deployment, Service and PVC in namespace ${NAMESPACE}…"
kubectl delete deployment nfs-ganesha -n "$NAMESPACE" --ignore-not-found
kubectl delete svc nfs-ganesha -n "$NAMESPACE" --ignore-not-found
kubectl delete pvc nfs-ganesha-data -n "$NAMESPACE" --ignore-not-found

echo "Deleting namespace ${NAMESPACE} (remaining resources within will be terminated)…"
kubectl delete namespace "$NAMESPACE" --ignore-not-found

echo "Uninstallation completed."