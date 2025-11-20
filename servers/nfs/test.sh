#!/bin/bash
set -e
echo "[INFO] Creating temporary test Job..."
kubectl apply -f test.yaml

echo "[INFO] Waiting for Job completion..."
kubectl wait --for=condition=complete job/nfs-test --timeout=180s

echo "[INFO] Job logs:"
kubectl logs -l job-name=nfs-test

echo "[INFO] Deleting Job..."
kubectl delete -f test.yaml
echo "[DONE] Test completed successfully."