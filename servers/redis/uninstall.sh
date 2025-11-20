#!/bin/bash
set -euo pipefail

helm uninstall redis-server --namespace redis-storage || true