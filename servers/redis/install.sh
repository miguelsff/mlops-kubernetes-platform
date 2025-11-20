#!/bin/bash
set -euo pipefail

helm upgrade --install redis-server redis-23.2.12.tgz -f config-redis.yaml --namespace redis-storage --create-namespace