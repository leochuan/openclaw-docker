#!/bin/bash
# Stop gateway and auto-commit config changes

docker compose down

DATA_DIR=$(grep '^OPENCLAW_CONFIG_DIR=' .env | cut -d= -f2)
DATA_ROOT=$(dirname "$DATA_DIR")

if [ -d "$DATA_ROOT/.git" ]; then
    CHANGES=$(git -C "$DATA_ROOT" status --porcelain)
    if [ -n "$CHANGES" ]; then
        echo "[sync] Config changes detected, committing..."
        git -C "$DATA_ROOT" add -A
        git -C "$DATA_ROOT" commit -m "auto: sync config $(date '+%Y-%m-%d %H:%M')"
        git -C "$DATA_ROOT" push
        echo "[sync] Pushed to remote."
    else
        echo "[sync] No config changes."
    fi
fi

echo "[done] Gateway stopped."
