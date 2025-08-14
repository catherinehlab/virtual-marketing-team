# Supabase + Telegram + Dashboard (MVP Patch)

## ENV (Vercel → Project → Settings → Environment Variables)
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY  (server only)
TELEGRAM_BOT_TOKEN         (prod only)
TELEGRAM_WEBHOOK_SECRET    (random string)

## DB
Run in Supabase SQL editor: supabase/migrations/2025-08-15_init.sql

## Dashboard
cd dashboard && npm i @supabase/supabase-js

## Webhook
export BASE_URL="https://<prod-domain>"
export TELEGRAM_BOT_TOKEN="***"
export TELEGRAM_WEBHOOK_SECRET="***"
bash scripts/register_telegram_webhook.sh

