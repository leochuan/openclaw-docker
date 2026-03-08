#!/bin/bash
# Pull latest config before starting gateway

DATA_DIR=$(grep '^OPENCLAW_CONFIG_DIR=' .env | cut -d= -f2)
DATA_ROOT=$(dirname "$DATA_DIR")

if [ -d "$DATA_ROOT/.git" ]; then
    echo "[sync] Pulling latest openclaw-data..."
    git -C "$DATA_ROOT" pull --rebase --autostash
fi

docker compose up -d openclaw-gateway
echo "[done] Gateway started."
