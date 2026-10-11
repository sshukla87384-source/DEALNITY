#!/usr/bin/env bash
# First-time .env for a NEW server. Generates every secret fresh and fills in
# the production wiring, so only the Telegram/payment values are left to add.
#
#   ./infrastructure/scripts/init-env.sh yourdomain.com YourBotUsername
#
# Never overwrites an existing .env (that would orphan every encrypted key).
set -euo pipefail
cd "$(dirname "$0")/../.."

DOMAIN="${1:-}"
BOTUSER="${2:-}"
[ -n "$DOMAIN" ] || { echo "usage: $0 <domain> [bot_username]"; exit 1; }
[ -f .env ] && { echo "ERROR: .env already exists — refusing to overwrite (its ENCRYPTION_MASTER_KEY decrypts your stock)."; exit 1; }
command -v openssl >/dev/null || { echo "ERROR: openssl not found"; exit 1; }

rnd() { openssl rand -hex "$1"; }
PGPW="$(rnd 24)"

cp .env.example .env
chmod 600 .env
set_kv() {
  local k="$1" v="$2"
  if grep -qE "^$k=" .env; then
    # | as the sed delimiter; secrets are hex so they never contain it.
    sed -i "s|^$k=.*|$k=$v|" .env
  else
    echo "$k=$v" >> .env
  fi
}
set_kv NODE_ENV production
set_kv BOT_MODE webhook
set_kv NGINX_DOMAIN "$DOMAIN"
set_kv WEBHOOK_DOMAIN "https://api.$DOMAIN"
set_kv PUBLIC_API_URL "https://api.$DOMAIN"
set_kv NEXT_PUBLIC_API_URL "https://api.$DOMAIN"
set_kv ADMIN_PANEL_ORIGIN "https://admin.$DOMAIN"
set_kv SEED_ADMIN_EMAIL "admin@$DOMAIN"
set_kv SEED_ADMIN_PASSWORD "$(rnd 12)"
set_kv POSTGRES_PASSWORD "$PGPW"
set_kv DATABASE_URL "postgresql://gis:$PGPW@postgres:5432/gis"
set_kv REDIS_URL "redis://redis:6379"
set_kv ENCRYPTION_MASTER_KEY "$(rnd 32)"
set_kv JWT_SECRET "$(rnd 32)"
set_kv WEBHOOK_SECRET_PATH "$(rnd 16)"
set_kv TELEGRAM_SECRET_TOKEN "$(rnd 24)"
set_kv BOT_ADMIN_PASSCODE "$(rnd 6)"
[ -n "$BOTUSER" ] && set_kv BOT_USERNAME "${BOTUSER#@}"

echo "✅ .env created with fresh secrets for $DOMAIN."
echo
echo "Still to fill in (nano .env):"
echo "  • BOT_TOKEN        — from @BotFather"
echo "  • BOT_ADMIN_IDS    — your Telegram numeric id"
echo "  • UPI_ID / BINANCE_PAY_UID / other payment values you use"
echo
echo "⚠️  Back up ENCRYPTION_MASTER_KEY offline NOW — without it saved keys/accounts can never be decrypted."
echo "    Your bot /admin passcode and web admin password are in .env (BOT_ADMIN_PASSCODE, SEED_ADMIN_PASSWORD)."
echo
echo "Then deploy:  ./infrastructure/scripts/deploy.sh full"
