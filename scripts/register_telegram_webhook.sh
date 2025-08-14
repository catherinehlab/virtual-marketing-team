#!/usr/bin/env bash
set -euo pipefail
: "${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN}"
: "${TELEGRAM_WEBHOOK_SECRET:?Missing TELEGRAM_WEBHOOK_SECRET}"
: "${BASE_URL:?Missing BASE_URL (e.g., https://your-domain)}"

WEBHOOK_URL="$BASE_URL/api/telegram/webhook/$TELEGRAM_WEBHOOK_SECRET"

curl -sS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook"   -d "url=${WEBHOOK_URL}"   -d "secret_token=${TELEGRAM_WEBHOOK_SECRET}"   -d "allowed_updates[]=message"   -d "allowed_updates[]=callback_query"
echo "Webhook set to: ${WEBHOOK_URL}"

